variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Cluster name prefix"
  type        = string
  default     = "capstone-phoenix"
}

variable "control_instance_type" {
  description = "EC2 instance type for control plane"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 instance type for workers"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "ssh_key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH (your IP)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block used by modules (for intra-cluster rules)"
  type        = string
  default     = "10.10.0.0/16"
}
