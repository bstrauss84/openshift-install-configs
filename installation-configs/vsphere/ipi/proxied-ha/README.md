# vSphere — IPI — Proxied — HA

Same as connected IPI, but with a **cluster-wide proxy** (see `proxy:`). Paste the proxy/registry CA into
`additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
