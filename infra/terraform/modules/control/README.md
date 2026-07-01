Control module placeholder

This module should create a single EC2 instance for the k3s server, security group rules, and outputs `public_ip` and `private_ip`.

Required variables (suggested):
- cluster_name
- instance_type
- ssh_key_name
- ssh_allowed_cidr

Outputs:
- public_ip
- private_ip
