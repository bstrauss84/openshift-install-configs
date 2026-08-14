# SR-IOV VF passthrough to an OpenShift Virtualization VM

**Goal:** Pass a hardware SR-IOV Virtual Function (VF) directly to a VM guest via VFIO, providing near-native network performance with minimal software overhead.

**Supported platforms:** bare metal, Red Hat OpenStack Platform (RHOSP). SR-IOV VF passthrough is not supported on vSphere, AWS, Azure, or GCP worker VMs.

## Files

- `sriov-network-node-policy.yaml`: Creates VFs on a physical NIC and registers them as an extended resource (`openshift.io/vmvf`). Uses `deviceType: vfio-pci` for VM passthrough.
- `sriov-network.yaml`: Defines the SR-IOV network. The **SR-IOV Network Operator automatically creates** a `NetworkAttachmentDefinition` in the target namespace. Do not create the NAD manually.
- `vm.yaml`: KubeVirt VM with a default pod network interface (masquerade) and a secondary SR-IOV interface.

## Resource flow

```
Physical NIC (PF)
  → SriovNetworkNodePolicy (creates VFs, binds vfio-pci driver)
    → VFs registered as extended resource: openshift.io/vmvf
      → SriovNetwork (operator generates NAD in vmtest namespace)
        → VM references NAD via multus networkName
          → Network Resources Injector auto-adds VF resource request to virt-launcher pod
            → KubeVirt/QEMU binds VF directly into VM guest
```

## Prerequisites

- **OpenShift Virtualization** (kubevirt-hyperconverged) operator installed.
- **SR-IOV Network Operator** installed from OperatorHub (`redhat-operators` catalog, channel `stable`).
- **Network Resources Injector enabled** (`spec.enableInjector: true`, the recommended configuration). The injector is a mutating admission webhook managed by the SR-IOV Network Operator. Verify:
  ```bash
  oc get sriovoperatorconfig default \
    -n openshift-sriov-network-operator \
    -o jsonpath='{.spec.enableInjector}{"\n"}'
  # Expected output: true
  ```
  When enabled, the injector automatically adds the SR-IOV extended-resource request (e.g., `openshift.io/vmvf: "1"`) to virt-launcher pod `resources.requests`/`limits` based on the SR-IOV NAD annotation. This is why the VM spec does not manually request `openshift.io/vmvf`. If the injector is disabled, automatic resource injection does not occur and the VM pod may not schedule correctly.
- **Bare metal or RHOSP infrastructure** — SR-IOV VF passthrough requires physical NIC access.
- **SR-IOV-capable NIC** certified in the [Red Hat Ecosystem Catalog](https://catalog.redhat.com). Common families: Intel X710/XXV710/E810, NVIDIA/Mellanox ConnectX-4/5/6.
- **SR-IOV enabled in BIOS/firmware** (VT-d / IOMMU). For Intel VFIO use, the SR-IOV Network Operator can configure the required IOMMU kernel arguments. If they are not already present, applying the policy can require a node reboot. SR-IOV/IOMMU must still be enabled in system firmware where required.
- **Physical switch port** configured as a trunk if using VLANs, or as an access port for untagged traffic.
- **Worker nodes** available for potential drain/reboot during policy application.

## Apply

```bash
# 1. Label target worker nodes (skip if using the NFD auto-label instead)
oc label node <worker-node> sriov-vm=true

# 2. Apply the SriovNetworkNodePolicy
#    WARNING: this may drain and reboot targeted nodes depending on NIC vendor/state.
oc apply -f sriov-network-node-policy.yaml

# 3. Wait for node configuration to complete
oc get sriovnetworknodestates -n openshift-sriov-network-operator -w

# 4. Create the target namespace if it does not exist
oc create namespace vmtest 2>/dev/null || true

# 5. Apply the SriovNetwork (operator auto-creates the NAD)
oc apply -f sriov-network.yaml

# 6. Verify the NAD was created
oc get network-attachment-definitions -n vmtest

# 7. Start the VM
oc -n vmtest apply -f vm.yaml
```

## How the VM gets scheduled

1. The `SriovNetworkNodePolicy` creates VFs on matching nodes and registers them as extended resource `openshift.io/vmvf`.
2. When the VM references the SR-IOV NAD, the **Network Resources Injector** (see Prerequisites) mutates the virt-launcher pod spec, automatically adding `openshift.io/vmvf: "1"` to `resources.requests` and `resources.limits`.
3. The Kubernetes scheduler places the pod only on nodes that have available `openshift.io/vmvf` resources.
4. If no node has available VFs, the VM remains **Pending/Unschedulable**. Check with: `oc get sriovnetworknodestates -n openshift-sriov-network-operator` and verify VFs are allocated.

You do **not** need to manually add resource requests to the VM spec when the Network Resources Injector is enabled.

## IPAM / IP addressing

`sriov-network.yaml` sets `ipam: "{}"` — an explicit empty IPAM configuration. The SR-IOV Network Operator renders this as `"ipam":{}` in the generated NAD. An omitted `spec.ipam` field produces the same result, but the explicit form makes the no-CNI-IPAM intent clear.

**Why no CNI IPAM:** With `deviceType: vfio-pci`, the VF is passed directly into the VM guest via VFIO — it appears as a physical NIC inside the guest OS. The host-side CNI stack has no path to configure IP addressing inside the VM guest.

**Guest interface addressing** is handled inside the VM, independent of CNI:
- DHCP on the physical VLAN/network
- Static configuration inside the guest
- cloud-init or Ignition

## VLAN behavior

The `vlan` field in `sriov-network.yaml` configures hardware-level VLAN tagging on the VF. When set:
- The VF applies 802.1Q tags at the hardware level before frames reach the physical switch.
- The VM guest sees untagged traffic — it does not need to configure a VLAN interface.
- The physical switch port must trunk (or natively carry) the specified VLAN.
- `vlan: 0` means untagged/native traffic (no VLAN tag applied).

## SR-IOV resource planning

OpenShift Virtualization allocates approximately **1 GiB additional VM memory overhead for each SR-IOV network device** attached to a VM. This is a general resource-planning consideration, not specific to live migration.

## Live migration

SR-IOV live migration is **supported** on x86_64 bare metal for OCP 4.18--4.22. No feature gate is required. Standard live-migration requirements still apply:
- **Shared storage**: VM disks must use ReadWriteMany (RWX) access mode.
- **Compatible target node**: must have available VFs from a matching `SriovNetworkNodePolicy`.
- **ARM64**: SR-IOV live migration is not supported on ARM64.

## Hot plug / hot unplug

- **SR-IOV hot plug** is supported (OCP 4.18+) — an SR-IOV interface can be added to a running VM.
- **SR-IOV hot unplug is not supported** — removing an SR-IOV interface requires a VM restart.
- **ARM64**: SR-IOV hot plug is not supported on ARM64.

## Disruption warnings

- **Applying a `SriovNetworkNodePolicy` may drain and reboot targeted nodes.** The operator reconfigures NIC firmware/driver settings, which can require a node reboot depending on the NIC vendor and current VF state.
- **Changing `numVfs` on an already-configured NIC is disruptive.** The operator drains the node, removes existing VFs, and re-creates them. Running VMs using those VFs are evicted.
- **Not all NICs behave identically.** Intel NICs typically require a reboot when VF configuration changes. Mellanox/NVIDIA NICs can often apply changes without a reboot. Consult vendor-specific documentation and test in a non-production environment.
- **Do not target control-plane nodes.** SR-IOV policies should only select worker nodes.

## Use SR-IOV when

- Direct VF access to a physical NIC is required.
- Very high bandwidth or very low latency is needed.
- Reduced software networking overhead is important.
- The workload can tolerate hardware-specific VF allocation and scheduling constraints.

## Prefer CUDN localnet / bridge networking when

- Normal VM secondary networking is sufficient.
- Live migration flexibility is more important than raw performance.
- Hardware-specific VF allocation is undesirable.
- Workloads do not need direct PCI/VF access.

The repository's `cudn-localnet` scenario remains the more general-purpose physical-network example.

## Items not physically validated

This scenario is validated offline against API schemas and documentation. The following hardware-dependent behaviors require physical validation in your environment:

- PF interface existence and naming on target nodes
- Actual NIC model and SR-IOV capability
- Requested `numVfs` within the NIC's hardware capability
- VF creation and driver binding (`vfio-pci`)
- BIOS/firmware SR-IOV and IOMMU (VT-d) configuration
- Real node drain/reboot behavior during policy application
- Physical switch port VLAN trunking configuration
- Guest L2/L3 connectivity over the passed-through VF
- Network throughput and latency characteristics
- Live migration on actual hardware with SR-IOV devices
- Interaction with site-specific network policies or firewalls

## Values you must change

| Field | File | What to replace |
|---|---|---|
| `pfNames` | `sriov-network-node-policy.yaml` | Your physical function NIC name (e.g., `ens1f0`, `enp65s0f0`) |
| `numVfs` | `sriov-network-node-policy.yaml` | VF count within your NIC's capability |
| `nodeSelector` | `sriov-network-node-policy.yaml` | Label matching your target worker nodes |
| `vlan` | `sriov-network.yaml` | Your VLAN ID (or 0 for untagged) |

**MTU alignment:** If you set `mtu` on the policy, ensure it matches the physical switch port and any intermediate infrastructure. A mismatch can cause silent drops or fragmentation.

**Warning:** Do not configure SR-IOV VFs on the NIC used for the cluster's primary network (br-ex / ovs-system). Use a dedicated secondary NIC.
