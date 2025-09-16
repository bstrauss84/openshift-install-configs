# Agent-based on bare metal — ${ver} deltas

- OVN-Kubernetes is the default and expected CNI.
- Prefer `imageDigestSources`; `imageContentSources` is legacy.
- Use `additionalTrustBundlePolicy: Always` whenever a bundle is provided (supported 4.18+ for agent-based installs).
- VIP behavior unchanged: with `platform.baremetal.apiVIPs/ingressVIPs`, the installer provides keepalived and haproxy for API and Ingress.
