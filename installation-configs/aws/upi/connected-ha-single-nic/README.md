# AWS — UPI — Connected — HA — Single NIC

User-provisioned AWS cluster (3+3). You must provide **VPC, subnets, security groups, EC2 instances, IAM, DNS**, and **LBs**.
- `platform: none` (no installer-managed LB/VIPs).
- SSH key (public) and pullSecret (single-line JSON) required.
