provider "aws" {
  region = var.aws_region
}

# Networking module placeholder
module "vpc" {
  source = "./modules/vpc"
  # fill required variables in a later PR
}

# Control plane (single k3s server)
module "control" {
  source = "./modules/control"
  cluster_name = var.cluster_name
  instance_type = var.control_instance_type
  ssh_key_name = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

# Workers
module "workers" {
  source = "./modules/worker"
  cluster_name = var.cluster_name
  instance_type = var.worker_instance_type
  count = var.worker_count
  ssh_key_name = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}
