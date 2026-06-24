output "public_ips" {
  value = [for i in aws_instance.worker : i.public_ip]
}

output "private_ips" {
  value = [for i in aws_instance.worker : i.private_ip]
}
