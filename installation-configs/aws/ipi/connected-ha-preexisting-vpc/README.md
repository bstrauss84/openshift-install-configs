# AWS — IPI — Connected — HA — Existing VPC (Multi-AZ)

**Installer-provisioned** cluster in your **existing VPC** with 3 control-plane and 3 worker nodes.
You provide the subnet IDs; the installer creates the LBs/SGs/NLB/ALB in that VPC.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Notes
- **No VIPs in AWS IPI**; ELB/ALB/NLB are managed by the installer.
- List **all subnets** (private and public) you want to use under `platform.aws.subnets`.
- `machineNetwork` must encompass the subnets you supply.
- Region/instance types/root volume can be tuned with `defaultMachinePlatform`.
