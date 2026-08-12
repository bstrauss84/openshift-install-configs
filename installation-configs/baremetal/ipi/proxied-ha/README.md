# Bare Metal -- IPI -- Proxied -- HA -- Single NIC

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on bare metal IPI with **installer-managed VIPs**, an **egress proxy**, **static IPs**, and a **single NIC per host**.

## Highlights
- **Proxied** install (cluster-wide egress proxy with `additionalTrustBundle`).
- **Single NIC** networking: each host uses one ethernet interface (`eno1`) with static IPv4.
- Internal load balancer managed by the installer (apiVIPs / ingressVIPs).
- Differentiates from the `connected-ha-bond` scenario by using a simpler single-NIC layout.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Steps
1. Prepare **SSH public key** and **pull secret (single-line JSON)** -- see comments at top of `install-config.yaml` for commands.
2. **Define `platform.baremetal.hosts`** with BMC details, boot MACs, rootDeviceHints, and `networkConfig` using a single ethernet NIC (`eno1`) with **static IPv4** (DNS/routes included).
3. Edit VIPs, domains, and optional fields as needed. Ensure enterprise proxy details are correct; add your proxy **CA** to `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
4. Update `proxy:` block with your proxy URLs.
5. Run:
   ```bash
   openshift-install create manifests
   openshift-install create cluster
   ```

## Notes
- If also disconnected, configure **imageDigestSources** and apply cluster resources from your mirroring workflow.
- `imageContentSources` is deprecated; prefer **imageDigestSources**.
