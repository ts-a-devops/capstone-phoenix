terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  cluster_name        = var.cluster_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
}

resource "aws_security_group" "cluster_internal" {
  name        = "${var.cluster_name}-internal-sg"
  description = "Intra-cluster: kube-apiserver, flannel VXLAN, kubelet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "kube-apiserver from VPC"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Flannel VXLAN from VPC"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Kubelet metrics from VPC"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "K3s WireGuard CNI from VPC"
    from_port   = 51820
    to_port     = 51821
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-internal-sg" }
}

module "control" {
  source                   = "./modules/control"
  cluster_name             = var.cluster_name
  instance_type            = var.control_instance_type
  ssh_key_name             = var.ssh_key_name
  ssh_allowed_cidr         = var.ssh_allowed_cidr
  vpc_id                   = module.vpc.vpc_id
  subnet_id                = module.vpc.public_subnet_ids[0]
  vpc_cidr                 = var.vpc_cidr
  extra_security_group_ids = [aws_security_group.cluster_internal.id]
}

module "workers" {
  source                   = "./modules/worker"
  cluster_name             = var.cluster_name
  instance_type            = var.worker_instance_type
  worker_count             = var.worker_count
  ssh_key_name             = var.ssh_key_name
  ssh_allowed_cidr         = var.ssh_allowed_cidr
  vpc_id                   = module.vpc.vpc_id
  public_subnet_ids        = module.vpc.public_subnet_ids
  vpc_cidr                 = var.vpc_cidr
  extra_security_group_ids = [aws_security_group.cluster_internal.id]
}
