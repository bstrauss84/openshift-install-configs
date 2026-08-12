# vSphere -- IPI -- Proxied -- HA -- Single Failure Domain

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on vSphere IPI with a **cluster-wide proxy** and a **single failure domain**.

## Highlights
- Uses the modern `platform.vsphere.vcenters[]` and `failureDomains[]` schema (preferred for 4.18+).
- Single failure domain (`fd-a`) -- all nodes land on one compute cluster / datastore.
- VIPs are **required** on vSphere IPI (`apiVIPs`, `ingressVIPs`).
- Include proxy CA in `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.

## Field to vSphere inventory mapping
| install-config field | vSphere object example |
|---|---|
| `vcenters[].server` | vCenter FQDN or IP |
| `failureDomains[].topology.datacenter` | Datacenter name |
| `failureDomains[].topology.datastore` | Datastore path |
| `failureDomains[].topology.networks[]` | Portgroup name |
| `failureDomains[].topology.computeCluster` | Cluster path |
| `failureDomains[].topology.folder` | VM folder path |

## Quick checklist
- Valid vCenter creds; API reachable
- Datacenter, cluster/resourcePool, folder exist
- Portgroup names match exactly
- Datastore has capacity/permissions
- DNS, NTP, and IP addressing accessible from ESXi hosts

Docs: vSphere install parameters, VIPs.
