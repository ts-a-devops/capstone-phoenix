output "public_ips" {
  description = "Public IPs of all worker instances"
  value       = [for i in aws_instance.worker : i.public_ip]
}

output "private_ips" {
  description = "Private IPs of all worker instances"
  value       = [for i in aws_instance.worker : i.private_ip]
}

output "instance_ids" {
  value = [for i in aws_instance.worker : i.id]
}
