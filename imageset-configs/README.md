# ImageSet configurations (oc-mirror v1 & v2)

### Get `oc-mirror` (matching your OpenShift & OS)

Download from Red Hat's client downloads page:
- https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/

Pick the **OpenShift version** you are installing/upgrading (e.g., 4.18, 4.19, 4.20),
then download the `oc-mirror` archive for your OS (RHEL 8/9).

Install to your PATH:

```bash
# Example for Linux x86_64
tar -xf oc-mirror-*-linux.tar.gz
chmod +x oc-mirror
sudo mv oc-mirror /usr/local/bin/
oc-mirror --help
```

See per-version folders. Each folder contains:
- `golden_all.yaml` (exact from templates/imageset-golden_all.yaml)
- `platform-only.yaml` (only the `platform:` slice)
- `operators-only.yaml` (only the `operators:` slice)
- `additionalimages-only.yaml` (only the `additionalImages:` slice)

## oc-mirror v1 (4.18/v1)

> Deprecated starting in 4.18 — migrate to v2 when possible.

### Mirror to disk → publish
```bash
oc-mirror --config ./4.18/v1/golden_all.yaml file://./mirror-dir
oc-mirror --from ./mirror-dir/mirror_seq1_000000.tar docker://registry.example.com
```

### Direct to registry
```bash
oc-mirror --config ./4.18/v1/operators-only.yaml docker://registry.example.com
```

### Useful flags (v1)
- --dry-run, --ignore-history, --max-per-registry, --skip-missing,
  --rebuild-catalogs=false, --dest-skip-tls, --dest-use-http

### Where artifacts land (v1)
`./oc-mirror-workspace/results-*/` → apply with `oc apply -f ./oc-mirror-workspace/results-*/ -R`

## oc-mirror v2 (4.18/v2, 4.19/v2, 4.20/v2)

### mirrorToDisk
```bash
oc-mirror -c ./4.19/v2/golden_all.yaml file:///path/to/mirror1 --v2
```

### diskToMirror
```bash
oc-mirror -c ./4.19/v2/golden_all.yaml --from file:///path/to/mirror1 docker://registry.example.com --v2
```

### mirrorToMirror
```bash
oc-mirror -c ./4.19/v2/operators-only.yaml --workspace file:///path/to/workspace docker://registry.example.com --v2
```

### Useful flags (v2)
- --cache-dir (big disk!), --parallel-images, --parallel-layers,
  --retry-times, --retry-delay, --strict-archive, --workspace,
  --dest-tls-verify=false

### Where artifacts land (v2)
`<workspace>/working-dir/cluster-resources/` → apply with `oc apply -f <workspace>/working-dir/cluster-resources/ -R`

### Subsequent runs
- Reuse the same `--workspace` and `--cache-dir` to accelerate.
- Use unique `targetCatalog` names to avoid overwriting existing catalogs.
- Use `--since YYYY-MM-DD` to mirror only new content since a date.

## Notes
- Keep two `imageDigestSources` in install-config.yaml (release + ART).
- For mirror registry setup see `utility-box/mirror-registry/`.
- If registry uses custom CA, add it to `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always` in install-config.yaml.
