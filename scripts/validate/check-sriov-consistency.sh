#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXIT_CODE=0

while IFS= read -r -d '' policy_file; do
  dir="$(dirname "$policy_file")"
  scenario_name="$(basename "$dir")"
  network_file="$dir/sriov-network.yaml"
  vm_file="$dir/vm.yaml"

  [ -f "$network_file" ] || continue
  [ -f "$vm_file" ] || continue

  python3 - "$policy_file" "$network_file" "$vm_file" "$scenario_name" <<'PYEOF' || EXIT_CODE=1
import yaml, sys

policy_file = sys.argv[1]
network_file = sys.argv[2]
vm_file = sys.argv[3]
scenario = sys.argv[4]

with open(policy_file) as f:
    policy = yaml.safe_load(f)
with open(network_file) as f:
    network = yaml.safe_load(f)
with open(vm_file) as f:
    vm = yaml.safe_load(f)

errors = []

# --- SriovNetworkNodePolicy checks ---
p_api = policy.get("apiVersion", "")
if p_api != "sriovnetwork.openshift.io/v1":
    errors.append(f"policy apiVersion='{p_api}', expected 'sriovnetwork.openshift.io/v1'")

p_ns = policy.get("metadata", {}).get("namespace", "")
if p_ns != "openshift-sriov-network-operator":
    errors.append(f"policy namespace='{p_ns}', expected 'openshift-sriov-network-operator'")

p_spec = policy.get("spec", {})
p_resource = p_spec.get("resourceName", "")
if not p_resource:
    errors.append("policy spec.resourceName is missing or empty")

p_numvfs = p_spec.get("numVfs", 0)
if not p_numvfs or p_numvfs <= 0:
    errors.append(f"policy spec.numVfs={p_numvfs}, must be > 0")

p_device_type = p_spec.get("deviceType", "")
if p_device_type != "vfio-pci":
    errors.append(f"policy spec.deviceType='{p_device_type}', expected 'vfio-pci' for VM passthrough")

p_nic = p_spec.get("nicSelector", {})
if not p_nic:
    errors.append("policy spec.nicSelector is missing or empty")
elif not any(p_nic.get(k) for k in ("pfNames", "rootDevices", "vendor", "deviceID", "netFilter")):
    errors.append("policy spec.nicSelector has no identifying field (pfNames, rootDevices, vendor, deviceID, or netFilter)")

# --- SriovNetwork checks ---
n_api = network.get("apiVersion", "")
if n_api != "sriovnetwork.openshift.io/v1":
    errors.append(f"network apiVersion='{n_api}', expected 'sriovnetwork.openshift.io/v1'")

n_ns = network.get("metadata", {}).get("namespace", "")
if n_ns != "openshift-sriov-network-operator":
    errors.append(f"network namespace='{n_ns}', expected 'openshift-sriov-network-operator'")

n_spec = network.get("spec", {})
n_resource = n_spec.get("resourceName", "")
if not n_resource:
    errors.append("network spec.resourceName is missing or empty")

n_net_ns = n_spec.get("networkNamespace", "")
if not n_net_ns:
    errors.append("network spec.networkNamespace is missing or empty")

n_name = network.get("metadata", {}).get("name", "")

# Cross-file: resourceName must match between policy and network
if p_resource and n_resource and p_resource != n_resource:
    errors.append(f"resourceName mismatch: policy='{p_resource}' != network='{n_resource}'")

# --- VM checks ---
vm_spec = vm.get("spec", {}).get("template", {}).get("spec", {})
vm_ns = vm.get("metadata", {}).get("namespace", "")
vm_domain = vm_spec.get("domain", {})
vm_devices = vm_domain.get("devices", {})
vm_ifaces = vm_devices.get("interfaces", [])
vm_networks = vm_spec.get("networks", [])

# Build lookup maps
iface_names = {iface.get("name", "") for iface in vm_ifaces}
net_names = {net.get("name", "") for net in vm_networks}

# Check SR-IOV interfaces have matching network entries
sriov_ifaces = [iface for iface in vm_ifaces if "sriov" in iface]
for iface in sriov_ifaces:
    iname = iface.get("name", "")
    if iname and iname not in net_names:
        errors.append(f"VM SR-IOV interface '{iname}' has no matching networks[] entry")

# Check multus networkName references
for net in vm_networks:
    nname = net.get("name", "")
    multus = net.get("multus", {})
    if multus:
        if nname and nname not in iface_names:
            errors.append(f"VM network '{nname}' has no matching interfaces[] entry")
        mn = multus.get("networkName", "")
        # networkName can be namespace-qualified: <ns>/<name>
        if "/" in mn:
            mn_ns, mn_name = mn.split("/", 1)
        else:
            mn_ns, mn_name = "", mn
        if n_name and mn_name and mn_name != n_name:
            errors.append(f"VM multus.networkName='{mn}' does not match SriovNetwork name='{n_name}'")
        if mn_ns and n_net_ns and mn_ns != n_net_ns:
            errors.append(f"VM multus networkName namespace='{mn_ns}' != SriovNetwork networkNamespace='{n_net_ns}'")

# Cross-file: VM namespace should agree with SriovNetwork networkNamespace
if vm_ns and n_net_ns and vm_ns != n_net_ns:
    errors.append(f"VM namespace='{vm_ns}' != SriovNetwork networkNamespace='{n_net_ns}'")

if errors:
    for e in errors:
        print(f"FAIL [{scenario}]: {e}")
    sys.exit(1)
PYEOF
done < <(find "$REPO_ROOT/virtualization-networking-configs" -name 'sriov-network-node-policy.yaml' -print0)

if [ $EXIT_CODE -eq 0 ]; then
  echo "All SR-IOV consistency checks passed."
fi
exit $EXIT_CODE
