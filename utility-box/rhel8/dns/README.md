# dnsmasq

Fields:
- `server=` upstream recursive resolvers
- `domain=` baseDomain from install-config.yaml
- `address=/api.<name>/` must resolve to your API VIP
- `address=/.apps.<name>.<baseDomain>/` must resolve to your Ingress VIP
- `host-record` and `ptr-record` must match your static host mappings if used
