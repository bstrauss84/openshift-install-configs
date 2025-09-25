# HAProxy external load balancer for OpenShift

This folder contains a **single canonical `haproxy.cfg`** you can use for **external load balancer** scenarios in user‑provisioned installs.

- Exposes:
  - **6443/TCP** (Kubernetes API) — health checks `/readyz` (HTTPS)
  - **22623/TCP** (Machine Config) — health checks `/healthz`
  - **443/TCP** and **80/TCP** (Ingress) — L4 (TCP) pass‑through

- Backends:
  - **Masters** for API + MCS
  - **Ingress** targets **workers by default**, but on **3‑node clusters** (no workers) the Ingress Controller runs on masters → this config points to **masters**. Switch to workers by uncommenting the worker lines if you have them.

## 1) Install & enable on RHEL 9

```bash
sudo dnf install -y haproxy
sudo setsebool -P haproxy_connect_any=1   # Allow haproxy to bind/connect (SELinux enforcing)
sudo install -o root -g root -m 0644 haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy
```

## 2) Firewalld

Open the ports:

```bash
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=22623/tcp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

## 3) DNS records to align with this LB

Point **VIP records** to the LB IPs (from `instructions.md` fake env):

- `api.cluster.example.com` → **10.90.0.10**
- `api-int.cluster.example.com` → **10.90.0.10**
- `*.apps.cluster.example.com` → **10.90.0.11**

## 4) Bootstrap lifecycle

Keep the `bootstrap` backend entries during install, then remove them **after** the control plane is initialized and etcd is healthy.

Check listening ports with:

```bash
sudo ss -lntp | egrep ':(6443|22623|443|80)'
```
