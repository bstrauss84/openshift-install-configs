# vSphere — IPI — Connected — HA — Multi Failure Domains

Deploy a 3×control-plane + 3×worker cluster across **three vSphere failure domains** (same vCenter/DC, different clusters/datastores).  
Uses modern `platform.vsphere.vcenters[]` and `failureDomains[]` plus **VIPs** (`apiVIPs`, `ingressVIPs`).

**Why this scenario?** Spreads nodes across zones for better availability while staying in one vCenter/DC.  
VIPs are required for vSphere IPI. The installer creates the VMs, configures VIPs, and wires up NSX/vSwitch networking.  
Docs: vSphere platform parameters & failure domains.

**Field → vSphere inventory mapping**
| install-config field | vSphere object example |
|---|---|
| `platform.vsphere.vCenter` | vCenter FQDN or IP |
| `platform.vsphere.datacenter` | Datacenter name |
| `platform.vsphere.defaultDatastore` | Datastore name |
| `platform.vsphere.network` | Portgroup name |
| `failureDomains[].topology.cluster` | Cluster or Resource Pool |
| `platform.vsphere.folder` | VM folder path |

**Quick checklist**
- Valid vCenter creds; API reachable
- Datacenter, cluster/resourcePool, folder exist
- Portgroup names match exactly
- Datastore has capacity/permissions
- DNS, NTP, and IP addressing accessible from ESXi hosts
