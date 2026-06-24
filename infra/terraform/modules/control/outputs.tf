output "public_ip" {
  value = aws_instance.control.public_ip
}

output "private_ip" {
  value = aws_instance.control.private_ip
}
