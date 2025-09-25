# AWS — UPI — Proxied — HA

Same as connected UPI, but with a **cluster-wide proxy**.
- Provide `httpProxy`, `httpsProxy`, and comprehensive `noProxy` coverage.
- Paste proxy CA/registry CA into `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
