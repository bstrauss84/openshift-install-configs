# Bare Metal -- Agent -- Proxied HA Internal-LB Static Single-NIC

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Proxied** -- internet access via HTTP/HTTPS proxy (`proxy.example.com:3128`); pull secret points to `registry.redhat.io` through the proxy.
- **HA topology**: 3 control-plane + 3 worker nodes.
- **Internal LB**: VIPs managed by the installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`) via `platform: baremetal`.
- **Static IPs on a single NIC** (`eno1`) -- the simplest bare-metal networking layout; no bonds, VLANs, or secondary NICs.
- **Agent-based installer**: boot hosts from the generated ISO (`openshift-install agent create image`).
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Proxy CA**: if your proxy terminates TLS with a custom CA, uncomment `additionalTrustBundle` and paste the PEM certificate.
- **noProxy**: includes cluster domain, service networks, RFC1918 ranges, and the API/Ingress VIPs to prevent proxy loops.
