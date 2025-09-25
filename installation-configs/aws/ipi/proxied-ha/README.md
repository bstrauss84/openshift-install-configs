# AWS — IPI — Proxied — HA

Same as connected IPI, but with a **cluster-wide proxy**.
- Provide `httpProxy`, `httpsProxy`, and a broad `noProxy` covering cluster domains and RFC1918 ranges.
- Paste the proxy CA (and/or registry CA) into `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
