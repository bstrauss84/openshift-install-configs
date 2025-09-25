# Bare Metal — Agent — Disconnected Sno Intlb Static Single Nic

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Internal LB**: VIPs managed by installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`).
- **Static addressing via NMState** in `agent-config.yaml`.
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.
