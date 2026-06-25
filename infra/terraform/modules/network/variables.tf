variable "compartment_ocid" {
  description = "OCID of the compartment to create network resources in."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource display names."
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
}
