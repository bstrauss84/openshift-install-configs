# Bare Metal — Agent — Disconnected 3Node Intlb Static Multi Subnet

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Internal LB**: VIPs managed by installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`).
- **Static addressing via NMState** in `agent-config.yaml`.
- **Multi-subnet**: control-plane on 10.90.0.0/24, workers on 10.91.0.0/24.
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.
