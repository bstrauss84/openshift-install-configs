# Mirror registry for Red Hat OpenShift — RHEL 9 quickstart (OpenShift 4.18)

This guide installs the **mirror registry for Red Hat OpenShift** (a minimal Quay) on a RHEL 9 host at **`registry.example.com`** (**10.90.0.4**), listening on **port 443**.

> Purpose: Host mirrored release payloads and operator content to install/update clusters in disconnected mode. Not HA, local storage only.

## 1) Prereqs

- RHEL 9 host with **podman**.
- Hostname resolves to **10.90.0.4** (DNS A record).
- Open firewall port **443/TCP**.
- Sufficient disk (hundreds of GB for operator catalogs).

```bash
sudo dnf -y install podman tar
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 2) Get the installer and install the registry

- Download `mirror-registry` from the **OpenShift console → Downloads** page.
- Then install it on the local host (writes under `$HOME/quay-install` by default):

```bash
chmod +x ./mirror-registry
./mirror-registry install --quayHostname registry.example.com
```

The installer sets up systemd units and starts containers. It also prints a generated **admin username/password** — save them.

## 3) Log in and trust the cert

If using a self-signed cert, add the CA to your **cluster’s** `additionalTrustBundle` during install. From this host:

```bash
podman login registry.example.com
# Username/password are printed by the installer (or in $HOME/quay-install/auth/)
```

## 4) oc-mirror and imagesets

- Use the `imageset-configs/` in this repo (4.18 v1/v2; 4.19–4.20 v2) to mirror content to `registry.example.com`.
- Keep two **imageDigestSources** entries in install configs (release + ART).

## 5) Services and troubleshooting

Systemd services created by the installer (names may vary by version):
- `quay-app.service`, `quay-postgres.service`, `quay-redis.service`, `quay-pod.service` (older releases use Postgres; newer may use SQLite).

Check status:

```bash
systemctl --user status quay-app
# or
sudo systemctl status quay-app
```

## 6) Notes (RHEL 9 vs 8)

- Mirror registry is **supported on RHEL 9**.
- The command‑line installer configures Podman & systemd automatically.
- Default port is **443** (you can change it with flags if needed).

## 7) Uninstall (if needed)

```bash
./mirror-registry uninstall
```

> After uninstall, consider removing `$HOME/quay-install/` and Podman volumes if you won’t reuse them.
