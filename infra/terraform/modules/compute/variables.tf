variable "compartment_ocid" {
  description = "OCID of the compartment to create instances in."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for instance display names and hostnames."
  type        = string
}

variable "subnet_id" {
  description = "OCID of the public subnet (from the network module)."
  type        = string
}

variable "nsg_id" {
  description = "OCID of the node NSG (from the security module)."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into every node."
  type        = string
}

variable "availability_domain_number" {
  description = "1-based index into the region's availability domains."
  type        = number
}

variable "os_operating_system" {
  description = "OS to match when resolving the node image."
  type        = string
}

variable "os_operating_system_version" {
  description = "OS version to match when resolving the node image."
  type        = string
}

# --- control-plane node ---
variable "server_shape" {
  description = "Compute shape for the k3s server."
  type        = string
}

variable "server_ocpus" {
  description = "OCPUs for the server (Flex shapes only)."
  type        = number
}

variable "server_memory_gb" {
  description = "Memory (GB) for the server (Flex shapes only)."
  type        = number
}

# --- worker nodes ---
variable "worker_shape" {
  description = "Compute shape for the k3s workers."
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes."
  type        = number
}

variable "worker_ocpus" {
  description = "OCPUs per worker (Flex shapes only)."
  type        = number
}

variable "worker_memory_gb" {
  description = "Memory (GB) per worker (Flex shapes only)."
  type        = number
}

variable "boot_volume_gb" {
  description = "Boot volume size (GB) per node."
  type        = number
}
