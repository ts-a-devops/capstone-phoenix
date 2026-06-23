output "control_public_ip" {
  description = "Public IP of control plane"
  value       = module.control.public_ip
}

output "worker_public_ips" {
  description = "Public IPs of worker nodes"
  value       = module.workers.public_ips
}

output "private_ips" {
  description = "Private IPs (all nodes)"
  value       = concat([module.control.private_ip], module.workers.private_ips)
}
