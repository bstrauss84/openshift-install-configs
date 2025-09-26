# All-in-one dnsmasq (DNS + DHCP + NTP advertisement) — RHEL 9

This folder provides a **single `dnsmasq.conf`** that serves:
- Authoritative DNS for **`example.com`** (and `cluster.example.com`) with cluster VIPs and node FQDNs.
- DHCP with a dynamic pool and **static reservations** for **3 control-plane + 3 worker** nodes.
- DHCP option **42** (`option:ntp-server`) pointing clients to the NTP server at **`10.90.0.2`**.

> dnsmasq **does not** run NTP; it only advertises it. Run **chrony** on `10.90.0.2` (example below).

The config matches the fake environment:
- Base domain `example.com`, cluster `cluster.example.com`
- Subnet `10.90.0.0/24`
- VIPs: API `10.90.0.10`, Ingress `10.90.0.11`
- DNS host: `10.90.0.3`
- NTP host: `10.90.0.2`
- Registry: `registry.example.com` → `10.90.0.4`

---

## 1) Install and enable on RHEL 9

```bash
sudo dnf install -y dnsmasq
sudo systemctl disable --now named || true  # if BIND was installed
```

Copy `dnsmasq.conf` into place and review the few `CHANGE_ME` items (MACs, optional NIC name):

```bash
sudo install -o root -g root -m 0644 dnsmasq.conf /etc/dnsmasq.conf
```

### Firewalld and SELinux

Open the required ports (DNS + DHCP):

```bash
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-port=67/udp  # DHCP server
sudo firewall-cmd --reload
```

> Lease file: on RHEL the default is `/var/lib/misc/dnsmasq.leases`. If you change it in the config, ensure the directory exists and SELinux labels are correct (use `restorecon -Rv` if needed).

---

## 2) Configure the utility-box networking

- Ensure this host has the IP **`10.90.0.3`** on the serving interface.
- If you want to restrict dnsmasq to a specific interface, set `interface=...` in the config.
- If your default **gateway** is not `10.90.0.1`, change the `dhcp-option=option:router` accordingly.

---

## 3) NTP: stand up chrony at 10.90.0.2

On the NTP server (which can be this same utility box if it also has `10.90.0.2` or an alias IP), configure **chrony**:

```bash
sudo dnf install -y chrony
sudo bash -c 'cat >/etc/chrony.conf <<EOF
# Minimal chrony for lab
server time.cloudflare.com iburst
server time.google.com iburst
# Serve time to the lab subnet
allow 10.90.0.0/24
local stratum 8
# Record drift
driftfile /var/lib/chrony/drift
makestep 1.0 3
logdir /var/log/chrony
EOF'
sudo systemctl enable --now chronyd
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```

> If fully **disconnected**, replace the public `server` lines with your upstream’s internal NTP or remove them and rely on a designated stratum in your environment.

---

## 4) Start dnsmasq

```bash
sudo systemctl enable --now dnsmasq
sudo systemctl status dnsmasq --no-pager
```

---

## 5) Verifications

```bash
# DNS
dig +short api.cluster.example.com @10.90.0.3
dig +short api-int.cluster.example.com @10.90.0.3
dig +short apps.cluster.example.com @10.90.0.3   # wildcard -> 10.90.0.11
dig +short registry.example.com @10.90.0.3

# DHCP leases (RHEL default path):
sudo tail -f /var/lib/misc/dnsmasq.leases

# Logs (if enabled)
sudo journalctl -u dnsmasq -f
```

---

## 6) Optional PXE/iPXE/TFTP

Uncomment the PXE/TFTP lines in `dnsmasq.conf`, then:

```bash
sudo dnf install -y tftp-server syslinux
sudo mkdir -p /var/lib/tftpboot
sudo firewall-cmd --permanent --add-service=tftp
sudo firewall-cmd --reload
# Put your bootloader/kernel/initrd into /var/lib/tftpboot
```

---

## 7) Notes & Tips

- If fully **disconnected**, change the `server=` lines to internal resolvers or comment them out.
- This config **publishes** the cluster VIPs:
  - `api.cluster.example.com` → **10.90.0.10**
  - `api-int.cluster.example.com` → **10.90.0.10**
  - `*.apps.cluster.example.com` → **10.90.0.11**
- Nodes reserved by MAC:
  - `cluster-master0..2` → `10.90.0.20–.22`
  - `cluster-worker0..2` → `10.90.0.30–.32`
- DHCP dynamic pool **does not** overlap the static reservations (`.100–.199`).
- Security: open ports **53/tcp, 53/udp, 67/udp** on the host firewall. Keep `bind-interfaces` enabled.
