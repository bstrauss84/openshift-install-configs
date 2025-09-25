# Multi‑VLAN on OVS (trunk)

**Goal:** Provide an OVS bridge on a dedicated NIC acting as a **trunk** for multiple VLANs.
Attach VMs to a single OVN localnet NAD; segment traffic upstream or via VLAN tagging inside the guest OS.

## Files

- `nncp.yaml`: Creates `br0` (OVS) with `enp2s0` uplink and adds a `vlan-trunk-net` localnet mapping.
- `nad.yaml`: OVN localnet NAD for the trunk.
- `vm.yaml`: Example VM attaching the trunk.

## Approaches to VLANs

- **In-guest VLAN tagging**: configure VLAN subinterfaces inside the VM. The trunk passes tags through `br0`.
- **Upstream segmentation**: the switchport facing `enp2s0` is a trunk; upstream network applies VLAN policy.
- For per‑VLAN NADs, you may instead use **Linux bridge plugin** (`cnv-bridge`) with `"vlan": <id>` in the NAD config,
  but that is **not** the OVN localnet path used here.

## Rollback

Same as the OVS dedicated NIC scenario: set interface `state: absent` and localnet `state: absent`, re-apply, then delete NNCP after success.
