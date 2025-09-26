# Broken-out services (DNS / DHCP / NTP) — RHEL 9

This directory presents **separate** configs for DNS (`dnsmasq`), DHCP (`dnsmasq`), and NTP (`chrony`) so you can deploy them on **different hosts** or as distinct services on the same host.

- `dns/`  → `dnsmasq` **DNS-only** config (no DHCP)
- `dhcp/` → `dnsmasq` **DHCP-only** config (no DNS)
- `ntp/`  → `chrony` server config

For a simpler single-host deployment, the **all-in-one** variant under `../all-in-one-dnsmasq/` is easier. Use this broken-out set when you need to split duties, segment security, or scale out.

---

## 0) Lab assumptions (fake environment)

- Base domain: `example.com`, cluster domain: `cluster.example.com`
- Subnet: `10.90.0.0/24`
- VIPs: API `10.90.0.10`, Ingress `10.90.0.11`
- DNS host: `10.90.0.3`
- NTP host: `10.90.0.2`
- Registry: `registry.example.com` → `10.90.0.4`
- Nodes (static DHCP reservations):
  - control plane: `10.90.0.20–10.90.0.22`
  - workers: `10.90.0.30–10.90.0.32`

---

## 1) DNS-only quick start (on 10.90.0.3)

```bash
sudo dnf install -y dnsmasq
sudo install -o root -g root -m 0644 dns/dnsmasq.conf /etc/dnsmasq.d/dns-only.conf
# Use a tiny main config that includes only the DNS file:
echo 'conf-file=/etc/dnsmasq.d/dns-only.conf' | sudo tee /etc/dnsmasq.conf

# Firewalld
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload

sudo systemctl enable --now dnsmasq
sudo systemctl status dnsmasq --no-pager
```

**What this does**

- Listens on 10.90.0.3:53 with bind-interfaces.
- Publishes cluster VIPs and (optionally) node FQDN A-records.
- Uses 1.1.1.1 and 8.8.8.8 as upstreams (change/remove for disconnected).

**Optional**

- Uncomment node host-record= lines to publish cluster-*.cluster.example.com → static IPs.
- Add PTRs via ptr-record= if you want reverse lookups.

**Verify**

```bash
dig +short api.cluster.example.com @10.90.0.3
dig +short api-int.cluster.example.com @10.90.0.3
dig +short apps.cluster.example.com @10.90.0.3   # wildcard -> 10.90.0.11
dig +short registry.example.com @10.90.0.3
```

---

## 2) DHCP-only quick start (on a DHCP host)

```bash
sudo dnf install -y dnsmasq
sudo install -o root -g root -m 0644 dhcp/dnsmasq.conf /etc/dnsmasq.d/dhcp-only.conf
# Tiny main config that includes only the DHCP file:
echo 'conf-file=/etc/dnsmasq.d/dhcp-only.conf' | sudo tee /etc/dnsmasq.conf

# Firewalld
sudo firewall-cmd --permanent --add-port=67/udp
sudo firewall-cmd --reload

sudo systemctl enable --now dnsmasq
sudo systemctl status dnsmasq --no-pager
```

**What this does**

- Disables DNS (`port=0`) and serves only DHCPv4 for 10.90.0.0/24.
- Hands out .100–.199 dynamically, with static reservations for the six nodes.
- Advertises default gateway 10.90.0.1, DNS 10.90.0.3, search domains cluster.example.com, example.com, and NTP 10.90.0.2.

**Before you start**

- Replace `CHANGE_ME_MAC_*` with the real NIC MAC addresses.
- If the host has multiple NICs, you can restrict DHCP to one with `interface=`….

**Verify**

```bash
sudo tail -f /var/lib/misc/dnsmasq.leases
journalctl -u dnsmasq -f
```

**Tip:** Keep hostnames in DHCP short (e.g., cluster-master0). The DNS server publishes the FQDN A-records.

---

## 3) NTP (chrony) quick start (on 10.90.0.2)

```bash
sudo dnf install -y chrony
sudo install -o root -g root -m 0644 ntp/chrony.conf /etc/chrony.conf

sudo systemctl enable --now chronyd
sudo systemctl status chronyd --no-pager

# Firewalld
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```

**What this does**

- Serves NTP to 10.90.0.0/24.
- Syncs to pool.ntp.org by default (replace with your org’s upstream for disconnected).
- Can be pinned to 10.90.0.2 with `bindaddress` if that host is multi-homed.

**Verify**

```bash
chronyc tracking
chronyc sources -v
```

---

## 4) Running all three on one host (optional)

You can run DNS and DHCP on one host and NTP on another, or all three on one host.  
If all on one host, choose either the broken-out pair (two separate include files) or the all-in-one config — not both at once.

**All-in-one path:** use `../all-in-one-dnsmasq/dnsmasq.conf` (simplest).  
**Broken-out on one host:** keep two include files and do not set `port=0` in the DNS file.

Example single host includes:

```ini
# /etc/dnsmasq.conf
conf-file=/etc/dnsmasq.d/dns-only.conf
conf-file=/etc/dnsmasq.d/dhcp-only.conf
```

---

## 5) Troubleshooting

- **DNS:** `dig @10.90.0.3 api.cluster.example.com`
- **DHCP:** watch `/var/lib/misc/dnsmasq.leases` and `journalctl -u dnsmasq -f`
- **Ports:** ensure 53/tcp, 53/udp (DNS) and 67/udp (DHCP) are open on the right host(s).
- **Conflicts:** make sure no other DHCP/DNS services (like `named` or `isc-dhcpd`) are running.
- **SELinux:** if you change lease/log locations, run `restorecon -Rv /var/lib/misc /var/log`.

---

## 6) Why this split?

- Security boundaries (separate boxes/segments).
- Scalability (DNS caching on bigger VM, DHCP on edge).
- Clear failure domains (NTP can be redundant elsewhere).
