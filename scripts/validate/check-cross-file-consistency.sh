#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXIT_CODE=0

while IFS= read -r -d '' ic_file; do
  dir="$(dirname "$ic_file")"
  scenario_name="$(basename "$dir")"
  agent_config="$dir/agent-config.yaml"
  scenario_yaml="$dir/scenario.yaml"

  [ -f "$agent_config" ] || continue
  [ -f "$scenario_yaml" ] || continue

  python3 - "$ic_file" "$agent_config" "$scenario_yaml" "$scenario_name" <<'PYEOF' || EXIT_CODE=1
import yaml, sys, ipaddress

ic_file = sys.argv[1]
ac_file = sys.argv[2]
sc_file = sys.argv[3]
scenario = sys.argv[4]

with open(ic_file) as f:
    ic = yaml.safe_load(f)
with open(ac_file) as f:
    ac = yaml.safe_load(f)
with open(sc_file) as f:
    sc = yaml.safe_load(f)

errors = []

ic_name = ic.get("metadata", {}).get("name", "")
ac_name = ac.get("metadata", {}).get("name", "")
if ic_name != ac_name:
    errors.append(f"install-config metadata.name='{ic_name}' != agent-config metadata.name='{ac_name}'")

ic_replicas_cp = ic.get("controlPlane", {}).get("replicas", 0)
compute = ic.get("compute", [])
ic_replicas_w = compute[0].get("replicas", 0) if compute else 0

hosts = ac.get("hosts", [])
masters = sum(1 for h in hosts if h.get("role") == "master")
workers = sum(1 for h in hosts if h.get("role") == "worker")

if masters != ic_replicas_cp:
    errors.append(f"install-config controlPlane.replicas={ic_replicas_cp} but agent-config has {masters} master hosts")
if workers != ic_replicas_w:
    errors.append(f"install-config compute.replicas={ic_replicas_w} but agent-config has {workers} worker hosts")

sc_cp = sc.get("nodes", {}).get("controlPlane", 0)
sc_w = sc.get("nodes", {}).get("workers", 0)
if sc_cp and sc_cp != ic_replicas_cp:
    errors.append(f"scenario.yaml controlPlane={sc_cp} != install-config replicas={ic_replicas_cp}")
if sc_w and sc_w != ic_replicas_w:
    errors.append(f"scenario.yaml workers={sc_w} != install-config replicas={ic_replicas_w}")

# VIP consistency: compare install-config apiVIPs with scenario.yaml vips.api
ic_platform = ic.get("platform", {})
sc_vips = sc.get("vips", {})
if sc_vips:
    sc_api_vip = sc_vips.get("api", "")
    # Normalize to list (scenario vips.api can be a string or a list for dualstack)
    if isinstance(sc_api_vip, list):
        sc_api_vip_list = sc_api_vip
    else:
        sc_api_vip_list = [sc_api_vip] if sc_api_vip else []
    # Check baremetal/vsphere apiVIPs
    for plat_key in ("baremetal", "vsphere"):
        plat_data = ic_platform.get(plat_key, {})
        ic_api_vips = plat_data.get("apiVIPs", [])
        if ic_api_vips and sc_api_vip_list:
            if set(sc_api_vip_list) != set(ic_api_vips):
                errors.append(f"scenario vips.api={sc_api_vip_list} != install-config platform.{plat_key}.apiVIPs={ic_api_vips}")

# machineNetwork/IP consistency: check host IPs fall within machineNetwork CIDRs
networking = ic.get("networking", {})
machine_networks = networking.get("machineNetwork", [])
if machine_networks and hosts:
    cidrs = []
    for mn in machine_networks:
        cidr_str = mn.get("cidr", "")
        if cidr_str:
            try:
                cidrs.append(ipaddress.ip_network(cidr_str, strict=False))
            except ValueError:
                pass
    if cidrs:
        for h in hosts:
            host_name = h.get("hostname", "unknown")
            nc = h.get("networkConfig", {})
            all_ips = []
            has_dhcp = False
            for iface in nc.get("interfaces", []):
                for proto in ("ipv4", "ipv6"):
                    proto_cfg = iface.get(proto, {})
                    if proto_cfg.get("dhcp"):
                        has_dhcp = True
                        continue
                    for addr in proto_cfg.get("address", []):
                        ip_str = addr.get("ip", "")
                        if ip_str:
                            all_ips.append(ip_str)
            if has_dhcp:
                continue
            if all_ips:
                has_match = False
                for ip_str in all_ips:
                    try:
                        ip = ipaddress.ip_address(ip_str)
                        if any(ip in cidr for cidr in cidrs):
                            has_match = True
                            break
                    except ValueError:
                        continue
                if not has_match:
                    errors.append(f"host '{host_name}' has no IP within machineNetwork {[str(c) for c in cidrs]}: {all_ips}")

if errors:
    for e in errors:
        print(f"FAIL [{scenario}]: {e}")
    sys.exit(1)
PYEOF
done < <(find "$REPO_ROOT/installation-configs" -name 'install-config.yaml' -print0)

if [ $EXIT_CODE -eq 0 ]; then
  echo "All cross-file consistency checks passed."
fi
exit $EXIT_CODE
