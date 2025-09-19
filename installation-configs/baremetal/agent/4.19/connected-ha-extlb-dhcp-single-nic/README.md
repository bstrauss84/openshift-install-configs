# connected-ha-extlb-dhcp-single-nic

Notes:
- All examples use OVN-Kubernetes.
- Pull secret must be a single-line JSON string. Validate with `jq -c . pull-secret.json`.
- SSH public key only. Generate one if needed:
  `ssh-keygen -t ed25519 -N "" -f ~/.ssh/ocp_ed25519`

VIP behavior:
- With `platform.baremetal.apiVIPs` and `ingressVIPs`, installer handles keepalived and haproxy.
- If you set `platform: none` you must provide external load balancers.

NTP:
- If DHCP Option 42 is present, you typically do not need `additionalNTPSources`.
- Otherwise specify at least two internal sources. NTP is UDP/123 and is not proxied.

RootDeviceHints:
- Prefer by-path hints. You can discover paths with `udevadm info --query=path --name /dev/sdX` and `lsblk -o NAME,MODEL,SERIAL`.
