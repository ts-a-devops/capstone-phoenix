output "public_ip" {
  description = "Public IP of the control-plane node"
  value       = aws_instance.control.public_ip
}

output "private_ip" {
  description = "Private IP — used as k3s server address for agent join"
  value       = aws_instance.control.private_ip
}

output "instance_id" {
  value = aws_instance.control.id
}
