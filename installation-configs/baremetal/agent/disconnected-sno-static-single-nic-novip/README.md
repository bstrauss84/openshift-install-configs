# Bare Metal — Agent — Disconnected Sno Static Single Nic (No VIP)

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **No VIPs on SNO**: `platform: none` in `install-config.yaml`. API and apps should resolve directly to the node IP instead of VIPs.
- **Static addressing via NMState** in `agent-config.yaml`.
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.
