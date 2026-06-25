# Availability domains are tenancy-wide; index in with availability_domain_number. In a
# single-AD region, capacity is dodged via fault domains / retries rather than this index.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Latest matching image PER SHAPE — server and worker may run different architectures
# (e.g. arm64 server + an x86 worker as a capacity fallback), so resolve each separately.
data "oci_core_images" "server" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.os_operating_system
  operating_system_version = var.os_operating_system_version
  shape                    = var.server_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_core_images" "worker" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.os_operating_system
  operating_system_version = var.os_operating_system_version
  shape                    = var.worker_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  ad_name         = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_number - 1].name
  server_image_id = data.oci_core_images.server.images[0].id
  worker_image_id = data.oci_core_images.worker.images[0].id
  # file() does not expand "~"; pathexpand() does.
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "oci_core_instance" "server" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  display_name        = "${var.name_prefix}-server"
  shape               = var.server_shape

  shape_config {
    ocpus         = var.server_ocpus
    memory_in_gbs = var.server_memory_gb
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    nsg_ids          = [var.nsg_id]
    assign_public_ip = true
    hostname_label   = "${var.name_prefix}-server"
  }

  source_details {
    source_type             = "image"
    source_id               = local.server_image_id
    boot_volume_size_in_gbs = var.boot_volume_gb
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
}

resource "oci_core_instance" "worker" {
  count               = var.worker_count
  compartment_id      = var.compartment_ocid
  availability_domain = local.ad_name
  display_name        = "${var.name_prefix}-worker-${count.index + 1}"
  shape               = var.worker_shape

  shape_config {
    ocpus         = var.worker_ocpus
    memory_in_gbs = var.worker_memory_gb
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    nsg_ids          = [var.nsg_id]
    assign_public_ip = true
    hostname_label   = "${var.name_prefix}-worker-${count.index + 1}"
  }

  source_details {
    source_type             = "image"
    source_id               = local.worker_image_id
    boot_volume_size_in_gbs = var.boot_volume_gb
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
}
