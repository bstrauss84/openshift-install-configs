# OpenShift Disconnected Install — Golden Standard Config Files

These opinionated examples are meant to be a practical baseline for disconnected and connected OpenShift installs, with a heavy emphasis on agent-based bare metal and oc-mirror workflows. Everything here sticks to Red Hat documentation and supported knobs for the versions noted.

\# \1 Cross-file consistency that matters
- **Subnets:** Any static IPs in `agent-config.yaml` must be within the `machineNetwork` CIDRs in `install-config.yaml`.
- **VIPs:** API and Ingress VIPs must reside on a `machineNetwork` and be reachable from hosts’ default gateway.
- **Hostnames:** Use fully qualified names; DNS must resolve hostnames, `api.<name>.<baseDomain>`, and `*.apps.<name>.<baseDomain>`.
- **FIPS:** If you set `fips: true` in the install config, run the installer from a RHEL 9 host with FIPS enabled and use the matching `openshift-install` for the exact target version from https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/.
- **Pull secret formatting:** Embed as single-line JSON; validate with `jq -c . pull-secret.json`.

\# \1 oc-mirror quick reference
- **v1 (`mirror.openshift.io/v1alpha2`)**: `oc mirror --config <file> docker://REGISTRY` or `file://` for multi-hop. Output under `results/` and `workspaces/`.
- **v2 (`mirror.openshift.io/v2alpha1`)**: Always use `--workspace file://./workdir` and reuse the same path for differential updates. Cluster resources land under `workdir/cluster-resources` (IDMS/ITMS/CS/CC).

See `SOURCES.md` for the documentation that justifies key choices.

---

<!-- __GS_IPI_EXPANDED__ -->
\# \1 IPI templates updated

- Bare metal IPI now includes fully commented `hosts[]` with `networkConfig` (bonds), `provisioningNetwork: Disabled`, and `apiVIPs`/`ingressVIPs` semantics.
- AWS and vSphere IPI examples expanded with realistic fields and proxy guidance.
- Agent-based install-configs do **not** use `hosts: []`; those are removed.

\# \1 oc-mirror quick guide (v2 vs v1)

- **v2** (`apiVersion: mirror.openshift.io/v2alpha1`): run from a stable `--workspace`; outputs under `working-dir/cluster-resources/` (IDMS/ITMS/CatalogSource/CatalogContent). Apply the cluster-scoped resources first on a connected admin host with cluster access.
- **v1** (`apiVersion: mirror.openshift.io/v1alpha2`): outputs under `results-<timestamp>/`; apply generated manifests (IDMS/ITMS on newer minors, or ICSP on older) plus CatalogSources.
- To discover default channels for operators on a given minor:
  `oc-mirror list operators --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.18 --version=4.18`
  Replace `4.18` with your minor.
- Include `graph: true` under `mirror.platform` to mirror OpenShift Update Service graph data for that minor.

