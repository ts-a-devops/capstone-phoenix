data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "worker_sg" {
  name   = "${var.cluster_name}-worker-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # Allow node-to-node & K3s agent traffic from within the VPC
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [var.vpc_cidr]
  }

  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_instance" "worker" {
  count                  = var.count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = element(var.public_subnet_ids, count.index % length(var.public_subnet_ids))
  associate_public_ip_address = true
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  tags = { Name = "${var.cluster_name}-worker-${count.index}" }
}
