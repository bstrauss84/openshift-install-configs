# dhcpd

Fields:
- `option domain-name-servers` should point at your DNS servers that resolve the cluster domain
- `option ntp-servers` distributes NTP via DHCP Option 42; omit `additionalNTPSources` in agent-config.yaml if using this
- Static `host` stanzas: MAC addresses must match host NICs used during discovery
