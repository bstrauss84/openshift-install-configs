# Single NIC — br-ex localnet

**Goal:** Let VMs reach the external network when cluster nodes only have one NIC. We **don’t** reconfigure `br-ex`; we just add an **OVN localnet** mapping and a NAD.

## Files

- `nncp.yaml`: Adds `ovn.bridge-mappings` → `localnet: br-ex-network` on `bridge: br-ex` with `state: present`.
- `nad.yaml`: OVN **localnet** NAD (`type: ovn-k8s-cni-overlay`, `topology: localnet`) referencing that mapping.
- `vm.yaml`: KubeVirt VM attaching the NAD. No IPAM in the NAD; VM gets IP via external DHCP or manual config.

## Apply

```bash
oc apply -f nncp.yaml
oc -n vmtest apply -f nad.yaml
oc -n vmtest apply -f vm.yaml
```

> **Heads-up:** IP Address Management (IPAM) in NADs is **not supported** for VMs. Use DHCP or static IP inside the guest.

## Rollback safely

1. Delete the VM and the NAD:
   ```bash
   oc -n vmtest delete network-attachment-definition/br-ex-network
   ```
2. Switch `state: present` → `state: absent` in `nncp.yaml` and re-apply:
   ```bash
   oc apply -f nncp.yaml
   ```
3. Confirm NNCP/NNCE report **SuccessfullyConfigured** and then delete the NNCP:
   ```bash
   oc delete nncp/br-ex-network
   ```

## Warnings

- **Do not** create additional bridges on the **same physical NIC** that backs `br-ex`. Use this localnet mapping approach to avoid disrupting cluster networking.
