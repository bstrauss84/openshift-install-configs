# Bare Metal -- Agent -- Connected HA Internal-LB Static Single-NIC

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Connected** (direct internet access) -- pull secret points to `registry.redhat.io`.
- **HA topology**: 3 control-plane + 3 worker nodes.
- **Internal LB**: VIPs managed by the installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`) via `platform: baremetal`.
- **Static IPs on a single NIC** (`eno1`) -- the simplest bare-metal networking layout; no bonds, VLANs, or secondary NICs.
- **Agent-based installer**: boot hosts from the generated ISO (`openshift-install agent create image`).
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **If converting to disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated (both shown as commented templates).
