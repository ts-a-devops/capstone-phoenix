variable "cluster_name" { type = string }
variable "instance_type" { type = string }
variable "count" { type = number }
variable "ssh_key_name" { type = string }
variable "ssh_allowed_cidr" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "vpc_cidr" { type = string }
