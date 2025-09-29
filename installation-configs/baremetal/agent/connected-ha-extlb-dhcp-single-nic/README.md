# Bare Metal — Agent — Connected Ha Extlb Dhcp Single Nic

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **External LB** required. See `utility-box/load-balancer/haproxy.cfg`.
- **DHCP addressing** (no static IP keys in NMState).
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.

**DHCP expectations:** Control-plane and worker nodes receive IP, default route, and DNS via DHCP reservations.  
**Rendezvous IP:** Reserve the rendezvous node's IP address in DHCP to keep it stable for the bootstrap flow.
