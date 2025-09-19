# OVS bridge secondary network (day 2)

Order:
1. Apply NNCP to create an OVS bridge (ovs-br-ext) on each node and attach the desired NIC (example: eno3).
2. Wait for NNCP Available=True on targeted nodes.
3. Apply the NAD referencing `bridge: ovs-br-ext` with the ovs-cni type.
4. Verify from a test pod or VirtualMachine.

Notes:
- OVN-Kubernetes primary CNI.
- Make sure `ovs-vswitchd` is present on nodes (provided by cluster node image).
