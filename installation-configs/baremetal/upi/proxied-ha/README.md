# Bare Metal — UPI — Proxied — HA

Same as connected UPI, but includes a **cluster-wide proxy**.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Key points
- `platform: none` (no installer-managed VIPs) — use an **external load balancer**.
- Use our canonical **HAProxy** example in `utility-box/load-balancer/haproxy.cfg`.
- DNS should map:
  - `api.cluster.example.com` and `api-int.cluster.example.com` → 10.90.0.10
  - `*.apps.cluster.example.com` → 10.90.0.11
- Update `proxy:` values and add your **proxy CA** in `additionalTrustBundle` with `additionalTrustBundlePolicy: Always`.
- If also disconnected, prefer **imageDigestSources**; `imageContentSources` is deprecated.

## Typical UPI flow
```bash
openshift-install create manifests
openshift-install create ignition-configs   # UPI: you host/attach Ignition; the installer does not provision nodes
# Stand up LB, DNS, and Ignition hosting (or ISO/virtual media)
# Boot machines with Ignition, monitor bootstrap and install
