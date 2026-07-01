output "control_public_ip" {
  description = "Public IP of the k3s control-plane node"
  value       = module.control.public_ip
}

output "control_private_ip" {
  description = "Private IP of the control-plane node (used by Ansible for kube-apiserver address)"
  value       = module.control.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of all worker nodes"
  value       = module.workers.public_ips
}

output "worker_private_ips" {
  description = "Private IPs of all worker nodes"
  value       = module.workers.private_ips
}

output "all_public_ips" {
  description = "All node public IPs (control first, then workers) — paste into Ansible inventory"
  value       = concat([module.control.public_ip], module.workers.public_ips)
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
