# OCI provider authentication is handled out-of-band via ~/.oci/config (an API signing key —
# see notes/oracle-cloud-setup.md §3). No tenancy OCIDs, fingerprints, or keys live in this repo.
provider "oci" {
  config_file_profile = var.oci_config_profile
  region              = var.region
}

variable "oci_config_profile" {
  description = "Profile name in ~/.oci/config to use for API-key auth."
  type        = string
  default     = "DEFAULT"
}

variable "region" {
  description = "OCI region identifier (e.g. uk-london-1). Must be your tenancy home region to stay on Always Free."
  type        = string
}
