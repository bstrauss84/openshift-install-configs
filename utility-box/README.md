# Utility Box

A small set of ready-to-tweak configs for on-prem helpers. These are not productized components; they are here so you can stand up a simple DNS/DHCP/NTP/mirror-registry/LB quickly on RHEL 8 or 9.

Each folder has:
- A short README
- A real config file format (not YAML-ified)
- Notes on common pitfalls

General tips:
- api and *.apps A records must point to your chosen VIPs when using bare metal with platform.baremetal and apiVIPs/ingressVIPs.
- For agent-based installs, api-int is usually not required.
- If DHCP Option 42 provides NTP, you normally do not need extra chrony servers on nodes. NTP is UDP/123 and is not proxied. You can run `chronyc sources -v` from a node for a quick sanity check after install.
