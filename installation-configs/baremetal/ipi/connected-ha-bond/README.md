# Bare Metal -- IPI -- Connected -- HA -- Bonded NICs

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on bare metal IPI with **installer-managed VIPs**, **bonded NICs** (LACP 802.3ad, eno1+eno2), and **static IPs**.

## Highlights
- **Connected** install (direct internet, no proxy).
- **Bond** networking: each host uses a 2-port LACP bond (`bond-labnet`) with jumbo frames (MTU 9000).
- **Static IPv4** addressing with per-host `networkConfig` (DNS resolver + default route).
- Internal load balancer managed by the installer (apiVIPs / ingressVIPs).

## Files
- `install-config.yaml`
- `scenario.yaml`

## Steps
1. Prepare **SSH public key** and **pull secret (single-line JSON)** -- see comments at top of `install-config.yaml` for commands.
2. **Define `platform.baremetal.hosts`** with BMC details, boot MACs, rootDeviceHints, and `networkConfig` using a 2-port LACP bond (`bond-labnet`) with **static IPv4** (DNS/routes included).
3. Edit VIPs, domains, and optional fields as needed.
4. Run:
   ```bash
   openshift-install create manifests
   openshift-install create cluster
   ```

## Notes
- If using a custom CA (proxy or mirror), add to `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
- For disconnected environments, prefer **imageDigestSources**; `imageContentSources` is deprecated.
