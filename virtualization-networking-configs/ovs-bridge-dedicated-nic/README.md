# OVS bridge on a dedicated NIC

**Goal:** Use an additional NIC (e.g., `enp2s0`) to create `br0` (OVS), map a localnet, and attach VMs via an OVN localnet NAD.

## Files

- `nncp.yaml`: Creates `br0` (OVS) with `enp2s0` as a port, enables STP, and adds `ovn.bridge-mappings` → `localnet: br0-network`.
- `nad.yaml`: OVN localnet NAD for `br0-network`.
- `vm.yaml`: KubeVirt VM attaching the NAD.

## Apply

```bash
oc apply -f nncp.yaml
oc -n vmtest apply -f nad.yaml
oc -n vmtest apply -f vm.yaml
```

## Rollback safely

- Edit `nncp.yaml`: set `interfaces[0].state: absent` and the mapping `state: absent`, then re-apply:
  ```bash
  oc apply -f nncp.yaml
  ```
- When NNCP/NNCE settle to **SuccessfullyConfigured**, delete the NNCP.

## Notes

- If your NIC name differs from `enp2s0`, change it under `port: - name:`.
- VLAN‑tagged and untagged frames can traverse this bridge; VMs can tag traffic in‑guest or you can segment upstream.

**MTU alignment:** Ensure the MTU configured on bridges/OVS/localnet matches the underlay. A mismatch can cause silent drops/fragmentation issues.

**Warning:** Do not bind the same physical NIC to multiple bridges. Reuse can lead to conflicts, loss of connectivity, and unpredictable failovers.
