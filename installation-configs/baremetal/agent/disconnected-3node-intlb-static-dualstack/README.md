# Bare Metal — Agent — Disconnected 3Node Intlb Static Dual-Stack (IPv4+IPv6)

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Internal LB**: VIPs managed by installer (dual-stack `apiVIPs` and `ingressVIPs` with IPv4 first, then IPv6).
- **Static addressing via NMState** in `agent-config.yaml` (IPv4 + IPv6 on the same VLAN interface).
- **Dual-stack**: `machineNetwork` lists IPv4 then IPv6; VIP lists are also IPv4 then IPv6.
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.
