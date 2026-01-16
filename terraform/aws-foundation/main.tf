terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  subnet_id = data.aws_subnets.default_vpc_subnets.ids[0]
}

# -------------------------
# Internet access (IGW + default route)
# Your default VPC currently has no Internet Gateway attached
# -------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name    = "${var.project}-${var.env}-igw"
    Project = var.project
    Env     = var.env
  }
}

data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# Manage the main/default route table and ensure 0.0.0.0/0 goes to our IGW
resource "aws_default_route_table" "main" {
  default_route_table_id = data.aws_route_table.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-${var.env}-main-rt"
    Project = var.project
    Env     = var.env
  }
}


resource "aws_route53_zone" "this" {
  name = var.domain_name
}

resource "aws_security_group" "k3s_sg" {
  name        = "${var.project}-${var.env}-sg"
  description = "SG for ${var.project} ${var.env} k3s demo"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "k3s" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.k3s_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.volume_size_gb
    volume_type = "gp3"
  }

  tags = {
    Name    = var.instance_name
    Project = var.project
    Env     = var.env
    Role    = "k3s"
  }
}

resource "aws_eip" "k3s_eip" {
  domain   = "vpc"
  instance = aws_instance.k3s.id

  tags = {
    Name    = "${var.instance_name}-eip"
    Project = var.project
    Env     = var.env
  }
}
