output "server_public_ip" {
  description = "Public IP of the k3s server (SSH + kubeconfig API endpoint)."
  value       = oci_core_instance.server.public_ip
}

output "server_private_ip" {
  description = "Private IP of the k3s server (agents join over this)."
  value       = oci_core_instance.server.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of the worker nodes (SSH)."
  value       = oci_core_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of the worker nodes."
  value       = oci_core_instance.worker[*].private_ip
}
