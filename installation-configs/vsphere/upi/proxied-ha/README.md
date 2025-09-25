# vSphere — UPI — Proxied — HA

Same as connected UPI, but with a **cluster-wide proxy**.
- Provide proxy URLs and strong `noProxy`.
- Paste proxy/registry CA into `additionalTrustBundle` + `additionalTrustBundlePolicy: Always`.
