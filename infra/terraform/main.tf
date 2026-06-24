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

# Cluster-level security group to allow Kubernetes API (6443) only from inside the VPC
resource "aws_security_group" "cluster_internal" {
  name        = "${var.cluster_name}-internal-sg"
  description = "Allow intra-cluster communication (kube-apiserver)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "kube-apiserver from VPC"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

# Pass the internal SG into control and worker modules so instances receive it
module "control" {
  source = "./modules/control"
  cluster_name = var.cluster_name
  instance_type = var.control_instance_type
  ssh_key_name = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  extra_security_group_ids = [aws_security_group.cluster_internal.id]
}

# Workers (redeclared with extra SG input)
module "workers" {
  source = "./modules/worker"
  cluster_name = var.cluster_name
  instance_type = var.worker_instance_type
  count = var.worker_count
  ssh_key_name = var.ssh_key_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_cidr = var.vpc_cidr
  extra_security_group_ids = [aws_security_group.cluster_internal.id]
}
