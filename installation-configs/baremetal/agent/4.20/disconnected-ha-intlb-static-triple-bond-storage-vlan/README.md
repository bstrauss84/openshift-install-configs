# Disconnected HA, internal LB, static IPs, triple bonds (install, VM/VLAN, storage)

- Six NICs per host forming three bonds (bond0 for install mgmt, bond1 for VM/VLAN traffic, bond2 for storage).
- agent-config shows one fully commented host; remaining hosts are minimal.
- Ensure static IPs fall inside the `machineNetwork` CIDR defined in install-config.yaml.
