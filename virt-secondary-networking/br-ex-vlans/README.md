# br-ex with VLAN sub-interfaces (day 2)

Order:
1. Apply NNCP to create `br-ex` and enslave the NIC that reaches your external L2 (example: eno4).
2. Optionally, add VLAN sub-interfaces (e.g., `br-ex.100`) to separate tenant/EGRESS traffic.
3. Wait for Available=True on nodes.
4. Apply NAD per VLAN you need (e.g., `ext-vlan100`).

Notes:
- OVN-Kubernetes is assumed.
- Use consistent MTU and verify upstream switch ports are trunking the same VLANs.
