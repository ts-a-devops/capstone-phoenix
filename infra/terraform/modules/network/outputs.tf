output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}

output "vcn_cidr" {
  description = "CIDR of the VCN (consumed by the security module for intra-cluster rules)."
  value       = var.vcn_cidr
}

output "subnet_id" {
  description = "OCID of the public subnet the nodes attach to."
  value       = oci_core_subnet.public.id
}
