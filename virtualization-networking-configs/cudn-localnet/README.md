# ClusterUserDefinedNetwork -- localnet topology

**Goal:** Use the `ClusterUserDefinedNetwork` (CUDN) API to attach VMs to the external network via OVN localnet. The CUDN auto-creates a `NetworkAttachmentDefinition` in every selected namespace, replacing the manual NAD-per-namespace pattern. The underlying OVN bridge-mapping (via NNCP) is still required.

**Requires:** OCP 4.19+ (CUDN localnet is GA in 4.19).

## Files

- `cudn.yaml`: Declares an `external-localnet` CUDN with `topology: Localnet`, `physicalNetworkName`, and `ipam.mode: Disabled`. VMs receive addresses from external DHCP or static cloud-init configuration.
- `nncp.yaml`: Prerequisite OVN bridge-mapping (Option A: reuse `br-ex`; Option B: dedicated NIC with new OVS bridge -- commented).
- `vm.yaml`: KubeVirt VM referencing the auto-created NAD by its CUDN name.

## Namespace setup

The CUDN uses `namespaceSelector` to select which namespaces receive the auto-created NAD. This example targets a namespace named `vmtest`:

```bash
oc create namespace vmtest
```

The `namespaceSelector` in `cudn.yaml` uses `kubernetes.io/metadata.name: vmtest`. To target additional namespaces, add their names to the `values` list, or use a label-based selector.

## Apply

```bash
# 1. Ensure the bridge-mapping exists
oc apply -f nncp.yaml

# 2. Create the CUDN (auto-creates NADs in target namespaces)
oc apply -f cudn.yaml

# 3. Verify the NAD was auto-created
oc -n vmtest get net-attach-def external-localnet

# 4. Launch a VM
oc -n vmtest apply -f vm.yaml
```

## How it differs from manual NAD

| Manual (pre-4.19)                    | CUDN (4.19+)                                         |
|--------------------------------------|------------------------------------------------------|
| Create NNCP + one NAD per namespace  | Create NNCP + one CUDN (NADs are auto-managed)       |
| NAD config is hand-written JSON      | CUDN spec is declarative YAML                        |
| Adding a namespace requires a new NAD| Adding a namespace requires only a label/selector match |

In both approaches, the NNCP bridge-mapping is required. The CUDN eliminates only the manual NAD creation step.

## Rollback

1. Delete VMs referencing the CUDN network.
2. Delete the CUDN: `oc delete clusteruserdefinednetwork external-localnet`
   (auto-created NADs are removed automatically)
3. Remove the bridge-mapping NNCP if no longer needed.

## Notes

- The CUDN `physicalNetworkName` value must exactly match the NNCP's `ovn.bridge-mappings[].localnet` name.
- With `ipam.mode: Disabled`, OVN does not manage IP addresses. VMs must receive addresses from external DHCP or static cloud-init configuration.
- For pre-4.19 clusters, use the `single-nic-br-ex-localnet` or `ovs-bridge-dedicated-nic` scenarios with manual NADs instead.

**MTU alignment:** Ensure the MTU configured on bridges/OVS/localnet matches the underlay. A mismatch can cause silent drops/fragmentation issues.
