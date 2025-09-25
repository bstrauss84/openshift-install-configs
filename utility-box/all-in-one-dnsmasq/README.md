# All-in-one dnsmasq (DNS + DHCP + NTP advertisement) — RHEL 9

This folder provides a **single `dnsmasq.conf`** that serves:
- Authoritative DNS for **`example.com`** and **`cluster.example.com`** (with **cluster VIPs**).
- DHCP with a dynamic pool and **static reservations** for **3 control-plane + 3 worker** nodes.
- DHCP option **42** (via `option:ntp-server`) pointing clients to the NTP server at **`10.90.0.2`**.

It is aligned with the `instructions.md` fake environment and uses **human‑readable** DHCP options (dnsmasq maps them to the correct numeric codes). See the dnsmasq man page for details (e.g. `option:router`, `option:dns-server`, `option:ntp-server`).

## 1) Install and enable on RHEL 9

```bash
sudo dnf install -y dnsmasq
sudo systemctl disable --now named || true  # if BIND was installed
```

Copy `dnsmasq.conf` into place:

```bash
sudo install -o root -g root -m 0644 dnsmasq.conf /etc/dnsmasq.conf
```

## 2) Firewalld and SELinux

Open the required ports (DNS + DHCP).

```bash
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-port=67/udp  # DHCP server
sudo firewall-cmd --reload
```

Reference: firewalld on RHEL 9 (services/ports).

## 3) Configure the network and start

- Ensure this host has the IP **`10.90.0.3`** on the serving interface.
- Update `dnsmasq.conf` **MAC addresses** under the `dhcp-host=` lines (`CHANGE_ME`).
- If your default gateway is not `10.90.0.1`, change `dhcp-option=option:router` accordingly.

Start and enable:

```bash
sudo systemctl enable --now dnsmasq
sudo systemctl status dnsmasq --no-pager
```

## 4) Verifications

```bash
# DNS
dig +short api.cluster.example.com @10.90.0.3
dig +short api-int.cluster.example.com @10.90.0.3
dig +short apps.cluster.example.com @10.90.0.3       # Wildcard test should return 10.90.0.11

# DHCP leases live here:
sudo tail -f /var/lib/misc/dnsmasq.leases

# Logs (if enabled in config)
sudo journalctl -u dnsmasq -f
```

## 5) Notes

- If fully **disconnected**, point the `server=` lines to an internal upstream resolver or comment them out.
- For **PXE**/iPXE/TFTP, uncomment the related lines and install `tftp-server` as needed.
- This setup intentionally **publishes** the VIPs for the cluster:
  - `api.cluster.example.com` → **10.90.0.10**
  - `api-int.cluster.example.com` → **10.90.0.10**
  - `*.apps.cluster.example.com` → **10.90.0.11**
- The **registry** name is pinned: `registry.example.com` → **10.90.0.4**.
