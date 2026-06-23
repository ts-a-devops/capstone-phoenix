Worker module placeholder

This module should create N worker EC2 instances, security group rules, and output a list `public_ips` and `private_ips`.

Required variables (suggested):
- cluster_name
- instance_type
- count
- ssh_key_name
- ssh_allowed_cidr

Outputs:
- public_ips
- private_ips
