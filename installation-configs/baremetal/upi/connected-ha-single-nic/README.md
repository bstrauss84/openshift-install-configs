# Bare Metal — UPI — Connected — HA — Single NIC

Deploy a **3 control-plane + 3 worker** HA OpenShift cluster on bare metal **UPI**.
UPI requires you to provide an **external load balancer**, DNS, and boot/ignition logistics.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Key points
- `platform: none` (no installer-managed VIPs).
- Use our canonical **HAProxy** example in `utility-box/load-balancer/haproxy.cfg`.
- DNS should map:
  - `api.cluster.example.com` and `api-int.cluster.example.com` → 10.90.0.10
  - `*.apps.cluster.example.com` → 10.90.0.11
- Pull secret must be **single-line JSON**; SSH key must be **public**.

## Typical UPI flow
```bash
openshift-install create manifests
# Stand up LB, DNS, and Ignition hosting (or ISO/virtual media)
# Boot machines with Ignition, monitor bootstrap and install
```
