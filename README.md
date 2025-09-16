# OpenShift Disconnected Install — Golden Standard Config Files

These opinionated examples are meant to be a practical baseline for disconnected and connected OpenShift installs, with a heavy emphasis on agent-based bare metal and oc-mirror workflows. Everything here sticks to Red Hat documentation and supported knobs for the versions noted.

## Cross-file consistency that matters
- **Subnets:** Any static IPs in `agent-config.yaml` must be within the `machineNetwork` CIDRs in `install-config.yaml`.
- **VIPs:** API and Ingress VIPs must reside on a `machineNetwork` and be reachable from hosts’ default gateway.
- **Hostnames:** Use fully qualified names; DNS must resolve hostnames, `api.<name>.<baseDomain>`, and `*.apps.<name>.<baseDomain>`.
- **FIPS:** If you set `fips: true` in the install config, run the installer from a RHEL 9 host with FIPS enabled and use the matching `openshift-install` for the exact target version from https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/.
- **Pull secret formatting:** Embed as single-line JSON; validate with `jq -c . pull-secret.json`.

## oc-mirror quick reference
- **v1 (`mirror.openshift.io/v1alpha2`)**: `oc mirror --config <file> docker://REGISTRY` or `file://` for multi-hop. Output under `results/` and `workspaces/`.
- **v2 (`mirror.openshift.io/v2alpha1`)**: Always use `--workspace file://./workdir` and reuse the same path for differential updates. Cluster resources land under `workdir/cluster-resources` (IDMS/ITMS/CS/CC).

See `SOURCES.md` for the documentation that justifies key choices.
