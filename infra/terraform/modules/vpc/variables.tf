variable "cluster_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "availability_zones" {
  description = "AZs to deploy subnets into — must match length of public_subnet_cidrs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
