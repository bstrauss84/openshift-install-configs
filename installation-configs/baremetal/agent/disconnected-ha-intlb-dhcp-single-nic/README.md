# Bare Metal -- Agent -- Disconnected HA Internal-LB DHCP Single-NIC

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Disconnected** (air-gapped) -- pull secret points to the mirror registry (`registry.example.com`); `imageDigestSources` is active.
- **HA topology**: 3 control-plane + 3 worker nodes.
- **Internal LB**: VIPs managed by the installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`) via `platform: baremetal`.
- **DHCP addressing on a single NIC** (`eno1`) -- IP, default route, and DNS are provided by the DHCP server.
- **Agent-based installer**: boot hosts from the generated ISO (`openshift-install agent create image`).
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated (kept as commented example).

**DHCP expectations:** Control-plane and worker nodes receive IP, default route, and DNS via DHCP reservations.
**Rendezvous IP:** Reserve the rendezvous node's IP address (`10.90.0.20`) in DHCP to keep it stable for the bootstrap flow.
