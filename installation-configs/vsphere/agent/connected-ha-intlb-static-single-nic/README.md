# vSphere -- Agent -- Connected -- HA -- Static, Single-NIC

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on vSphere using the **Agent-based installer** with **static IPv4 networking**.

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Agent-based installer on vSphere**: you pre-create VMs manually; the installer does not provision infrastructure.
- Uses the modern `platform.vsphere.vcenters[]` and `failureDomains[]` schema (preferred for 4.18+).
- Single failure domain (`fd-1`) -- intentionally simple. Multi-FD is shown in the IPI examples.
- This example specifies `topology.folder` intentionally. The field is optional in the vSphere schema, but required by the Agent installer when vCenter credentials are provided (assisted-service needs a real folder path to avoid placeholder-validation failures).
- This example uses the OpenShift-managed default load balancer. An external/user-managed load balancer is not required unless `platform.vsphere.loadBalancer.type` is set to `UserManaged`.
- **Static single-NIC networking** via NMState in `agent-config.yaml`.
- Interface name `ens192` reflects the VMXNET3 adapter standard on vSphere VMs. Actual interface names may vary by hardware version or adapter type (`ens160`, `ens256`).
- vCenter credentials are optional for the Agent install itself but recommended for post-install vSphere integration (CSI, Machine API).

## What Agent-based vSphere means

Unlike **IPI**, the Agent-based installer does **not** create or manage vSphere VMs. You are responsible for:
1. Creating VMs in vCenter with the correct hardware (CPU, RAM, disk, network adapter).
2. Recording each VM's actual NIC MAC address assigned by vCenter.
3. Replacing the example MAC values in `agent-config.yaml` with those actual addresses.
4. Mounting the Agent ISO as a CD/DVD drive and booting each VM from it.

The installer then:
1. Boots the Agent on each VM from the ISO.
2. Each Agent reports its MAC address, which the installer matches to `agent-config.yaml` host entries.
3. NMState networking is applied, giving each VM its static IP.
4. The rendezvous host (first control-plane) coordinates cluster bootstrap.
5. After installation, the `platform.vsphere` block configures the vSphere cloud provider (CSI storage, Machine API).

## Prerequisites
- vCenter accessible from the install host and from the VM network.
- 6 VMs pre-created with:
  - Control-plane: 4 vCPU, 16 GB RAM, 120 GB disk (minimum).
  - Worker: 2 vCPU, 8 GB RAM, 120 GB disk (minimum).
  - One VMXNET3 network adapter each, connected to the VM port group in `topology.networks`.
  - VM hardware version 13+ (ESXi 6.5+) recommended.
  - EFI firmware recommended (BIOS also works).
- DNS records:
  - `api.cluster.example.com` -> `10.90.0.10` (API VIP)
  - `api-int.cluster.example.com` -> `10.90.0.10` (API VIP)
  - `*.apps.cluster.example.com` -> `10.90.0.11` (Ingress VIP)
- VM folder (`/DC1/vm/openshift`) should exist in vCenter if `topology.folder` is specified.

## Workflow
```bash
# 1. Create 6 VMs in vCenter (3 control-plane, 3 worker) with VMXNET3 NICs
# 2. Record each VM's NIC MAC address:
#      vSphere Client > VM > Edit Settings > Network adapter 1 > MAC Address
# 3. Copy install-config.yaml and agent-config.yaml to a working directory
# 4. Replace example MACs in agent-config.yaml with actual VM MACs
# 5. Replace vCenter, datacenter, folder, and other placeholders in install-config.yaml
# 6. Generate the Agent ISO:
openshift-install agent create image --dir <install-dir>
# 7. Upload the ISO to a vSphere datastore or content library
# 8. For each VM: mount ISO as CD/DVD, set boot order to CD first, power on
# 9. Monitor installation:
openshift-install agent wait-for install-complete --dir <install-dir>
```

## Values you must change
| Placeholder | What to replace with |
|---|---|
| `vcenter.example.com` | Your vCenter FQDN or IP |
| `administrator@vsphere.local` | vCenter SSO username |
| `REPLACE_ME` (password) | vCenter password |
| `DC1` | Your datacenter name |
| `/DC1/host/Compute-Cluster` | Path to your compute cluster |
| `/DC1/host/.../Resources/openshift` | Path to your resource pool (or omit) |
| `/DC1/vm/openshift` | Path to your VM folder (or omit if credentials are also omitted) |
| `/DC1/datastore/datastore1` | Path to your datastore |
| `"VM Network"` | Your port group name |
| `00:50:56:3a:*` MAC addresses | Actual MAC addresses assigned to your VM NICs |
| `sshKey` | Your SSH public key |
| `pullSecret` | Your Red Hat pull secret (single-line JSON) |

## Notes
- `diskType`, `defaultMachinePlatform`, and `loadBalancer` are silently ignored by the Agent installer. They are not included in this example.
- `rootDeviceHints` uses `/dev/sda` (standard PVSCSI virtual disk). Omit if VMs have a single disk.
- Example MAC addresses use `00:50:56:3a:XX:01` from the VMware static range (`00:50:56:00-3F:XX:XX`). In practice, let vCenter auto-assign MACs and record the actual values rather than forcing VMs to match example addresses.
- If vCenter credentials are omitted, the cluster installs successfully but the vSphere cloud provider, CSI driver, and Machine API will not function until credentials are added post-install.
- For multi-failure-domain setups, see the vSphere IPI `connected-ha-multi-failure-domains` example and adapt the `failureDomains[]` block.
