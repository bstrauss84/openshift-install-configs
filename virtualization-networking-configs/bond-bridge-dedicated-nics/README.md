# Bond + Linux bridge on dedicated NICs

**Goal:** Bond two spare NICs (802.3ad LACP) into `bond1`, then create a Linux bridge `br1` on top for VM external connectivity with link redundancy.

## Files

- `nncp.yaml`: Creates `bond1` (802.3ad, miimon 100) from two NICs, then `br1` (Linux bridge, STP off) with `bond1` as its port.
- `nad.yaml`: `cnv-bridge` NAD pointing to `br1`.
- `vm.yaml`: KubeVirt VM attaching the NAD.

## Apply

```bash
oc apply -f nncp.yaml
oc -n vmtest apply -f nad.yaml
oc -n vmtest apply -f vm.yaml
```

## Rollback safely

1. Delete the VM and NAD.
2. Set both `br1` and `bond1` to `state: absent` in `nncp.yaml` and re-apply.
3. Wait for **SuccessfullyConfigured**, then delete the NNCP.

## Notes

- Change `enp7s0`/`enp8s0` in `nncp.yaml` to match your actual spare NICs.
- The upstream switch ports must be configured as an LACP trunk.
- No IPAM in the NAD; configure IP inside the guest via DHCP or static assignment.

**MTU alignment:** Ensure the MTU configured on bonds/bridges matches the underlay. A mismatch can cause silent drops/fragmentation issues.

**Warning:** Do not bind the same physical NIC to multiple bonds or bridges. Reuse can lead to conflicts, loss of connectivity, and unpredictable failovers.
