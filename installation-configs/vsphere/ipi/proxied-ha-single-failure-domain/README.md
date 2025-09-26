# vSphere — IPI — Proxied — HA — Single Failure Domain

Same as a standard connected IPI, but with a **cluster-wide proxy** and a **single vSphere domain** using classic keys.  
VIPs are still **required** on vSphere IPI. Include proxy CA in `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.  
Docs: vSphere install parameters, VIPs. :contentReference[oaicite:3]{index=3}
