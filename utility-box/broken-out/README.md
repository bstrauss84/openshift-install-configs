# Broken-out services (DNS / DHCP / NTP) — RHEL 9

This directory presents **separate** configs for DNS (`dnsmasq`), DHCP (`dnsmasq`), and NTP (`chrony`) to deploy them on **different hosts** or as distinct services.

- `dns/` → `dnsmasq` **DNS-only** config (no DHCP)
- `dhcp/` → `dnsmasq` **DHCP-only** config (no DNS)
- `ntp/` → `chrony` server config

For a simpler single-host deployment, prefer the **all-in-one** variant under `../all-in-one-dnsmasq/` (recommended), but some environments require this separation.

## DNS-only quick start

```bash
sudo dnf install -y dnsmasq
sudo install -o root -g root -m 0644 dns/dnsmasq.conf /etc/dnsmasq.d/dns-only.conf
echo 'conf-file=/etc/dnsmasq.d/dns-only.conf' | sudo tee /etc/dnsmasq.conf
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload
sudo systemctl enable --now dnsmasq
```

## DHCP-only quick start

```bash
sudo dnf install -y dnsmasq
sudo install -o root -g root -m 0644 dhcp/dnsmasq.conf /etc/dnsmasq.d/dhcp-only.conf
echo 'conf-file=/etc/dnsmasq.d/dhcp-only.conf' | sudo tee /etc/dnsmasq.conf
sudo firewall-cmd --permanent --add-port=67/udp
sudo firewall-cmd --reload
sudo systemctl enable --now dnsmasq
```

## NTP (chrony) quick start

```bash
sudo dnf install -y chrony
sudo install -o root -g root -m 0644 ntp/chrony.conf /etc/chrony.conf
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
sudo systemctl enable --now chronyd
```

> Tip: Replace pool servers in `chrony.conf` if your org provides authoritative NTP.
