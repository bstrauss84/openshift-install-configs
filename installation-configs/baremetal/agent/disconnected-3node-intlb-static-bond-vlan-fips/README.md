# Bare Metal — Agent — Disconnected 3Node Intlb Static Bond Vlan Fips

## Files
- `install-config.yaml`
- `agent-config.yaml`
- `scenario.yaml`

## Highlights
- **Internal LB**: VIPs managed by installer (`apiVIPs: 10.90.0.10`, `ingressVIPs: 10.90.0.11`).
- **Static addressing via NMState** in `agent-config.yaml`.
- **Bonding (802.3ad)** with VLAN subinterfaces (ID 100; and ID 200 for storage in the triple-bond scenario).
- **FIPS**: requires FIPS-enabled installer and running from FIPS-enabled RHEL host.
- **SSH public key** and **pullSecret (single-line JSON)** are required. See comments in files.
- **Disconnected**: prefer `imageDigestSources`; `imageContentSources` is deprecated and commented as a reminder.
