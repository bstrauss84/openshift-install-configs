#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXIT_CODE=0

while IFS= read -r -d '' agent_config; do
  dir="$(dirname "$agent_config")"
  scenario_name="$(basename "$dir")"

  python3 - "$agent_config" "$scenario_name" <<'PYEOF' || EXIT_CODE=1
import yaml, sys

agent_file = sys.argv[1]
scenario = sys.argv[2]

with open(agent_file) as f:
    doc = yaml.safe_load(f)

rvip = doc.get("rendezvousIP")
if not rvip:
    sys.exit(0)

hosts = doc.get("hosts", [])
if not hosts:
    sys.exit(0)

host_ips = set()
for h in hosts:
    nc = h.get("networkConfig", {})
    for iface in nc.get("interfaces", []):
        for proto in ("ipv4", "ipv6"):
            proto_cfg = iface.get(proto, {})
            if proto_cfg.get("dhcp"):
                host_ips.add("__DHCP__")
                continue
            for addr in proto_cfg.get("address", []):
                host_ips.add(addr.get("ip", ""))

if "__DHCP__" in host_ips:
    sys.exit(0)

if rvip not in host_ips:
    print(f"FAIL [{scenario}]: rendezvousIP {rvip} not found in any host static IP")
    print(f"  Host IPs found: {sorted(host_ips)}")
    sys.exit(1)
PYEOF
done < <(find "$REPO_ROOT/installation-configs" -name 'agent-config.yaml' -print0)

if [ $EXIT_CODE -eq 0 ]; then
  echo "All rendezvousIP values match a host IP (or are DHCP scenarios)."
fi
exit $EXIT_CODE
