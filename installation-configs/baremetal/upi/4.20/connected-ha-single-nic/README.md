# Connected HA single NIC

- With `platform.baremetal.apiVIPs/ingressVIPs`, the installer provisions keepalived and haproxy for VIPs.
- Use `platform: none` only when you provide external load balancers (or SNO).
