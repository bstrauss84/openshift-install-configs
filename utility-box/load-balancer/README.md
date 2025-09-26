# HAProxy external load balancer for OpenShift (UPI/external-LB)

This folder contains a **canonical `haproxy.cfg`** to front an OpenShift cluster when you **must provide an external load balancer** (e.g., bare metal UPI, vSphere UPI). It aligns with the fake environment:
- Base domain: `example.com`, cluster: `cluster.example.com`
- VIPs (DNS targets): API **10.90.0.10**, Ingress **10.90.0.11**
- Control-plane FQDNs: `cluster-master-{1..3}.cluster.example.com`
- (Optional) Worker FQDNs: `cluster-worker-{1..3}.cluster.example.com`
- Bootstrap FQDN: `bootstrap.cluster.example.com`

> The config uses **L4 TCP** for API/Ingress and performs **HTTP health checks** on the API (`/readyz`) and Machine Config Server (`/healthz`). API checks use TLS (`check-ssl verify none`).

---

## 1) Install & enable on RHEL 9

```bash
sudo dnf install -y haproxy
sudo setsebool -P haproxy_connect_any=1      # Allow haproxy to connect out (SELinux enforcing)
sudo install -o root -g root -m 0644 haproxy.cfg /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy
sudo systemctl status haproxy --no-pager
```

### Firewalld
```bash
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=22623/tcp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

---

## 2) DNS records to align with this LB

Point **VIP hostnames** at the **LB IP** (the address where HAProxy listens):

- `api.cluster.example.com` → **10.90.0.10**
- `api-int.cluster.example.com` → **10.90.0.10**
- `*.apps.cluster.example.com` → **10.90.0.11**

> Your backend server hostnames in `haproxy.cfg` (masters/workers/bootstrap) must resolve to the actual node IPs. Make sure your DNS has **A records** for those FQDNs (or use raw IPs in the `server` lines if you prefer).

---

## 3) Bootstrap lifecycle

Keep the `bootstrap` backend entries during install, then **remove them** after the control plane reports healthy (etcd up and bootstrap complete).

Quick check of listening sockets:
```bash
sudo ss -lntp | egrep ':(6443|22623|443|80)'
```

---

## 4) Choosing backend targets for Ingress

- **Standard clusters (workers present):** point 80/443 at **workers** (where router pods are scheduled by default).  
- **Compact 3‑node control-plane clusters:** point 80/443 at **masters** (router pods run on masters).  

In the sample `haproxy.cfg` both options are provided — **masters enabled**, **workers commented**. Pick the one that matches your topology and keep only one set.

---

## 5) Operational tips

- **Logging:** the config uses `option tcplog`. Check logs via `journalctl -u haproxy -f`.
- **Health checks:** API uses `GET /readyz` over TLS with `verify none`. MCS uses `GET /healthz`.
- **Name resolution:** If DNS for backends may be slow at boot, consider adding `default-server init-addr last,libc,none` (advanced).
- **TLS passthrough:** 443/80 listeners are pure TCP; OpenShift handles TLS termination at the routers.
- **Security:** lock down access to the LB ports to trusted networks only; HAProxy does not enforce auth.

---

## 6) Troubleshooting

- API health: `curl -k https://api.cluster.example.com:6443/readyz` should return **ok**.
- MCS health: `curl -s http://cluster-master-1.cluster.example.com:22623/healthz` → `ok` (once nodes are up).
- Backend reachability: `nc -vz <backend> 6443`, `22623`, `443`, `80`.
- HAProxy stats: you can enable a stats listener if desired (not included by default).

---

## 7) Compact vs full‑size examples

**Compact (3 control-plane, no workers):**
- Keep the **masters** in `ingress-router-443/80`.
- Remove the commented worker lines.

**Full‑size (3+ workers):**
- Comment or remove masters in `ingress-router-443/80`.
- Uncomment the **worker** lines and update hostnames to your environment.
