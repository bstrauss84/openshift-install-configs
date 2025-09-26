# Bare Metal — Agent — Disconnected Ha Intlb Static Bond Multiple Vlans - Including One For Storage

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Internal LB**: VIPs managed by installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`).
- **Static addressing via NMState** in `agent-config.yaml`.
- **Bonding (802.3ad)** with VLAN subinterfaces (ID 100; and ID 200 for storage in the bond scenario).
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.
