# AWS — IPI — Proxied — HA — New VPC

**Installer-provisioned** VPC with 3 control-plane and 3 worker nodes, behind a **cluster-wide proxy**.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Notes
- **No VIPs in AWS IPI**; AWS load balancers are managed by the installer.
- Set `region`, instance type, and root volume via `defaultMachinePlatform`.
- Provide `httpProxy`, `httpsProxy`, and a broad `noProxy` covering cluster domains, RFC1918 ranges, your VPC CIDR, and the EC2 metadata IP (`169.254.169.254`).
- Paste the proxy CA (and/or registry CA) into `additionalTrustBundle` and set `additionalTrustBundlePolicy: Always`.
