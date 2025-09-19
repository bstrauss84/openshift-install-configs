# Linux bridge secondary network (day 2)

Order:
1. Apply NNCP to create a Linux bridge (br-ext) on each node and enslave the desired NIC (example: eno2).
2. Wait for the NNCP `status.conditions` type Available to be True on all targeted nodes.
3. Apply the NetworkAttachmentDefinition (NAD) that references `bridge: br-ext`.
4. Verify attachment in a test pod or VirtualMachine by adding the network and ensuring link/IP.

Notes:
- OVN-Kubernetes is assumed as primary CNI.
- NNCP is cluster-scoped. NAD is namespaced.
- Keep MTU and VLAN choices consistent end-to-end.
