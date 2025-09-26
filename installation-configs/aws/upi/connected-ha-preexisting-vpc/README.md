# AWS — UPI — Connected — HA — Existing VPC (Multi-AZ)

UPI on AWS: you bring **all** infrastructure — VPC, subnets (multi-AZ), security groups, load balancers, Route53, and EC2 instances.
This example assumes an **existing VPC**. The installer only generates Ignition.

## Files
- `install-config.yaml`
- `scenario.yaml`

## Key points
- `platform: none` (installer does not create AWS resources in UPI).
- Create:
  - **NLB** for API (`:6443`) targeting masters; CNAME `api` and `api-int` to the NLB DNS name.
  - **ALB/NLB** for Ingress (`:80,:443`) targeting workers; CNAME `*.apps` to the LB DNS name.
  - Security groups/route tables/subnets across at least **three AZs** for HA.
- SSH key must be **public**; pullSecret must be **single-line JSON**.

## Typical UPI flow
```bash
openshift-install create manifests
openshift-install create ignition-configs
# Provision AWS infra (VPC/subnets/SGs/LBs/Route53/EC2)
# Attach/host Ignition, boot nodes, monitor bootstrap/install
