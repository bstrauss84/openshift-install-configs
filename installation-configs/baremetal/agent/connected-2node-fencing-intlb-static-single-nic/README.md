# Bare Metal -- Agent -- Connected Two-Node with Fencing (Static, Single-NIC)

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Two-Node with fencing (TNF)**: 2 control-plane nodes with BMC-based Pacemaker fencing (no arbiter node).
- **`controlPlane.replicas: 2`** with a **`fencing:`** sub-block containing exactly 2 Redfish BMC credentials.
- **`compute.replicas: 0`**: control-plane nodes are schedulable (run workloads directly).
- **Fencing credential hostnames** must match the `hostname` values in `agent-config.yaml`.
- **Redfish-only**: BMC addresses must contain `"redfish"` in the URL. IPMI is explicitly rejected.
- **Internal load balancer**: installer-managed VIPs (`apiVIPs` / `ingressVIPs`).
- **Static single-NIC networking** via NMState in `agent-config.yaml`.
- **GA in OCP 4.22**. Tech Preview in 4.20--4.21 (requires `featureSet: TechPreviewNoUpgrade`, not shown).

## How fencing works
When one control-plane node becomes unreachable, the surviving node uses the fencing credentials to power off the failed node via its Redfish BMC, then takes over the etcd leader role as a single-member quorum.

Post-install, the Cluster Etcd Operator automatically:
1. Detects the `DualReplica` control plane topology.
2. Configures Pacemaker with the `podman-etcd` resource agent on both nodes.
3. Applies the fencing credentials as STONITH devices.

A diagnostic tool (`/usr/local/bin/fencing_validator`) is deployed automatically to verify Pacemaker status and fencing configuration.

## Fencing credential fields
- **`hostname`**: Must match a control-plane hostname in `agent-config.yaml`. Alternative: `macAddress`.
- **`address`**: Redfish BMC URL. Accepted schemes: `redfish+https://`, `idrac-redfish+https://`, `ilo5-redfish+https://`.
- **`username`** / **`password`**: BMC credentials (required).
- **`certificateVerification`**: `Enabled` (default) or `Disabled`. Use `Disabled` for self-signed BMC certs.

## Notes
- Workers are NOT supported -- `compute.replicas` must be `0`.
- ZTP is not supported for TNF clusters.
- Replace `REPLACE_BMC_USER`, `REPLACE_BMC_PASS`, and the `address` URLs with your actual BMC credentials.
- The Redfish URL path typically follows: `/redfish/v1/Systems/<system_id>`.
- During degraded operation (one node down), cluster upgrades and MachineConfig reboots are unavailable.
