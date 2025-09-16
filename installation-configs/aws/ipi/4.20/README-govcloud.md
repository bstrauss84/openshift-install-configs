# AWS GovCloud (US) notes

- Supported partitions: us-gov-east-1 and us-gov-west-1.
- Public Route 53 zones are not supported. Clusters are typically private; bring your own VPC and subnets.
- Some services/endpoints differ from commercial regions. Validate IAM, ELB, and S3 constraints before installation.

See SOURCES.md for links.
