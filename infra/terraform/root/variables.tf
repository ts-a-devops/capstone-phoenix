# Root input variables. Provider-auth vars (region, oci_config_profile) live in provider.tf.
# Real values go in terraform.tfvars (gitignored); see terraform.tfvars.example.

variable "name_prefix" {
  description = "Prefix for naming/tagging all resources."
  type        = string
  default     = "phoenix"
}

variable "compartment_ocid" {
  description = "OCID of the compartment to provision into."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into every node (the private key never leaves your machine)."
  type        = string
  default     = "~/.ssh/oci_phoenix.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to reach SSH (22) and the k3s API (6443). Use your own IP /32."
  type        = string

  validation {
    condition     = var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "allowed_ssh_cidr must not be 0.0.0.0/0 — exposing SSH/6443 to the world violates the brief (§5)."
  }
}

# --- Networking ---
variable "vcn_cidr" {
  description = "CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet that holds the nodes."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_domain_number" {
  description = "1-based index into the region's availability domains. Bump this to dodge A1 'Out of host capacity'."
  type        = number
  default     = 1
}

# --- Nodes ---
variable "server_shape" {
  description = "Compute shape for the k3s control-plane node."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "worker_shape" {
  description = "Compute shape for the k3s worker nodes."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "worker_count" {
  description = "Number of k3s agent (worker) nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 2
    error_message = "worker_count must be >= 2 — the brief requires real multi-node scheduling."
  }
}

variable "server_ocpus" {
  description = "OCPUs for the control-plane node (Flex shapes only)."
  type        = number
  default     = 1
}

variable "server_memory_gb" {
  description = "Memory (GB) for the control-plane node (Flex shapes only)."
  type        = number
  default     = 6
}

variable "worker_ocpus" {
  description = "OCPUs per worker node (Flex shapes only)."
  type        = number
  default     = 1
}

variable "worker_memory_gb" {
  description = "Memory (GB) per worker node (Flex shapes only)."
  type        = number
  default     = 9
}

variable "boot_volume_gb" {
  description = "Boot volume size (GB) per node. 3x50 = 150 GB stays inside the 200 GB Always Free block-storage cap."
  type        = number
  default     = 50
}

# --- OS image (resolved via data lookup in the compute module — no hardcoded OCID) ---
variable "os_operating_system" {
  description = "Operating system to match when resolving the node image."
  type        = string
  default     = "Canonical Ubuntu"
}

variable "os_operating_system_version" {
  description = "OS version to match when resolving the node image (arm64 for Ampere A1)."
  type        = string
  default     = "22.04"
}
