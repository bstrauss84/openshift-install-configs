# Bare Metal — UPI — Proxied — HA

Same as connected UPI, but includes a **cluster-wide proxy**.
- Update `proxy:` values and add your **proxy CA** in `additionalTrustBundle` with `additionalTrustBundlePolicy: Always`.

If also disconnected:
- Prefer **imageDigestSources**; `imageContentSources` is deprecated and will be removed.
