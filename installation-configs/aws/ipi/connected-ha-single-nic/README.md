# AWS — IPI — Connected — HA — Single NIC

**Installer-provisioned** AWS cluster with 3 control-plane and 3 worker nodes.
The installer creates the VPC, subnets, security groups, and load balancers unless you supply your own.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Notes
- **AWS ELB/ALB are managed by the installer**; no VIPs are specified in AWS IPI `install-config.yaml`.
- Set the `region` and (optionally) AZs, instance types, and rootVolume.
- SSH key must be **public**; pullSecret must be **single-line JSON**.
