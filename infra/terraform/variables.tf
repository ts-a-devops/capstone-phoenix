variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Prefix applied to every resource name"
  type        = string
  default     = "capstone-phoenix"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "One CIDR per AZ — must match length of availability_zones"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "availability_zones" {
  description = "AZs for subnets — use at least 2 so workers spread across nodes"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "control_instance_type" {
  description = "EC2 instance type for the k3s control-plane node"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 instance type for k3s worker nodes"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Number of worker nodes (minimum 2 for HA scheduling)"
  type        = number
  default     = 2
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Your public IP in CIDR notation (e.g. 1.2.3.4/32) — only this IP can SSH"
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state (bootstrap via remote-state/)"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking (bootstrap via remote-state/)"
  type        = string
}
