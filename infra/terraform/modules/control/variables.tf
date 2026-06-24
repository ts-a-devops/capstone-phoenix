variable "cluster_name" { type = string }
variable "instance_type" { type = string }
variable "ssh_key_name" { type = string }
variable "ssh_allowed_cidr" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "extra_security_group_ids" {
	type = list(string)
	default = []
}
