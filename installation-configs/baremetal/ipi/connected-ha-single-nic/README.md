# Bare Metal — IPI — Connected — HA — Single NIC

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on bare metal IPI with **installer-managed VIPs**.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Steps
1. Prepare **SSH public key** and **pull secret (single line JSON)** — see comments at top of `install-config.yaml` for commands.
2. Edit VIPs, domains, and optional fields as needed.
3. Run:
   ```bash
   openshift-install create manifests
   openshift-install create cluster
   ```

Notes:
- If using a custom CA (proxy or mirror), add to `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
- For disconnected environments, prefer **imageDigestSources**; `imageContentSources` is deprecated.
