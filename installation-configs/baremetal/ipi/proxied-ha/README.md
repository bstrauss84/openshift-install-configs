# Bare Metal — IPI — Proxied — HA

Same as connected, but routes all egress via your **HTTP/HTTPS proxy** with correct `noProxy` coverage.

## Steps
- Update `proxy:` block, paste your proxy CA in `additionalTrustBundle`, set `additionalTrustBundlePolicy: Always`.
- Create cluster as normal.

If also disconnected, configure **imageDigestSources** and apply cluster resources from your mirroring workflow.
