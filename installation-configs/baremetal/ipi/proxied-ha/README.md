# Bare Metal — IPI — Proxied — HA — Static (2 Bonded NICs)

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on bare metal IPI with **installer-managed VIPs**, an **egress proxy**, **static IPs**, and **two bonded NICs per host**.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Steps
1. Prepare **SSH public key** and **pull secret (single line JSON)** — see comments at top of `install-config.yaml` for commands.
2. **Define `platform.baremetal.hosts`** with BMC details, boot MACs, and `networkConfig` using a 2-port LACP bond (`bond-labnet`) with **static IPv4** (DNS/routes included).
3. Edit VIPs, domains, and optional fields as needed. Ensure enterprise proxy details are correct; add your proxy **CA** to `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always` if required.
4. Update `proxy:` block, paste your proxy CA in `additionalTrustBundle`, set `additionalTrustBundlePolicy: Always`.
5. Run:
   ```bash
   openshift-install create manifests
   openshift-install create cluster

If also disconnected, configure **imageDigestSources** and apply cluster resources from your mirroring workflow.
