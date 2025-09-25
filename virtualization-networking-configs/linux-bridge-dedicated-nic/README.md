# Linux bridge on a dedicated NIC

**Goal:** Create a Linux bridge (`br1`) on a spare NIC (e.g., `enp8s0`) and attach VMs using the `cnv-bridge` NAD.

## Files

- `nncp.yaml`: Creates `br1` as a Linux bridge and adds `enp8s0` as a port (STP disabled).
- `nad.yaml`: CNV bridge NAD pointing directly to `br1`.
- `vm.yaml`: KubeVirt VM attaching the NAD.

## Apply

```bash
oc apply -f nncp.yaml
oc -n vmtest apply -f nad.yaml
oc -n vmtest apply -f vm.yaml
```

## Rollback safely

1. Delete the VM + NAD.
2. Edit `nncp.yaml`: set interface `state: absent` and re-apply.
3. Wait for **SuccessfullyConfigured**, then delete the NNCP.

## Notes

- This scenario assumes the external network **has no DHCP** — configure IP inside the guest.
- Default MTUs differ: OVS‑attached VIFs often show **1400**, Linux bridge VIFs **1500** by default (see OCP docs).
