# DNS labels must be <=15 alphanumeric chars starting with a letter — sanitize the prefix.
locals {
  dns_label = substr(lower(replace(var.name_prefix, "/[^a-zA-Z0-9]/", "")), 0, 15)
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.name_prefix}-vcn"
  dns_label      = local.dns_label
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

# Public subnet that holds all nodes. Edge firewalling is done with NSGs (security module),
# not this subnet's default security list — so node VNICs attach to the NSG explicitly.
resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = var.subnet_cidr
  display_name               = "${var.name_prefix}-public-subnet"
  route_table_id             = oci_core_route_table.public.id
  dns_label                  = "public"
  prohibit_public_ip_on_vnic = false
}
