# Mirror registry for Red Hat OpenShift — RHEL 9 Quickstart (OpenShift 4.18)

This guide installs and configures the **mirror registry for Red Hat OpenShift** (a lightweight Quay instance) on a RHEL 9 host at **`registry.example.com`** (**10.90.0.4**), listening on **port 443**.

> Purpose: Host mirrored release payloads and operator content to install/update clusters in disconnected mode. Not HA, single-node, local storage only.

---

## 1) Prerequisites

- **RHEL 9 host** with sudo, Podman, and tar installed.
- DNS A record: `registry.example.com` → **10.90.0.4**
- Firewall open: **443/TCP**
- **Storage**:
  - At least **200–500 GB** for release payloads + operator catalogs.
  - If using **oc-mirror v2**: plan **2× that space** (it uses a local workspace cache before pushing to the registry).
- Time sync: Ensure host runs **chrony** or syncs with lab NTP.

```bash
sudo dnf install -y podman tar
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

---

## 2) Install the mirror registry

1. Download `mirror-registry` from the **OpenShift console → Downloads** page.
2. Make it executable and run the installer:

```bash
chmod +x ./mirror-registry
./mirror-registry install --quayHostname registry.example.com
```

This will:
- Deploy Quay + Redis + database under `$HOME/quay-install/`
- Create systemd units and start containers
- Generate **admin credentials** (saved under `$HOME/quay-install/auth/`)

---

## 3) Certificates

The installer generates a **self-signed certificate** by default.

- If using this cert: Add the CA to your cluster’s `install-config.yaml` under `additionalTrustBundle`, and to your admin workstation trust store.
- If using a custom/enterprise CA: Supply it during install with `--sslCert` and `--sslKey`.

Verify registry is serving TLS:

```bash
curl -vk https://registry.example.com/v2/_catalog
```

---

## 4) Logging in

Use the credentials created by the installer (or found in `$HOME/quay-install/auth/`):

```bash
podman login registry.example.com
# Username: quayadmin
# Password: <generated>
```

---

## 5) Mirroring images

Use **oc-mirror** to populate your registry.

### Example (connected → mirror):

```bash
oc-mirror --config=imageset-config.yaml docker://registry.example.com:443
```

### Example (fully disconnected workflow):

1. Connected site:
   ```bash
   oc-mirror --config=imageset-config.yaml file://mirror-dir
   ```
   Copy `mirror-dir/` to the disconnected site.

2. Disconnected site:
   ```bash
   oc-mirror --from mirror-dir docker://registry.example.com:443
   ```

Both workflows generate:
- **ImageContentSourcePolicy (ICSP)**
- **CatalogSource**
- **IDMS/ITMS manifests** for cluster use

---

## 6) Systemd services

The installer creates services such as:

- `quay-app.service`
- `quay-redis.service`
- `quay-postgres.service` (or SQLite on newer releases)

Check status:

```bash
systemctl --user status quay-app
# or (depending on install mode)
sudo systemctl status quay-app
```

---

## 7) Uninstall (if needed)

```bash
./mirror-registry uninstall
```

Then remove `$HOME/quay-install/` and Podman volumes if you won’t reuse them.

---

## 8) Best practices

- Always mirror **both release payload and ART images** (two `imageDigestSources`).
- For production, back up the registry storage volume and Quay database.
- If deploying multiple clusters, tag operator catalogs by version.
- Monitor disk usage regularly (oc-mirror v2 can consume **double** storage during runs).

---

## References

- [Disconnected Environments Documentation (OCP 4.18, PDF)](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/pdf/disconnected_environments/OpenShift_Container_Platform-4.18-Disconnected_environments-en-US.pdf)

---
