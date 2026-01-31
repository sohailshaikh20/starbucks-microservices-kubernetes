terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "eu-north-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Fetch latest Ubuntu 22.04 AMI (region-safe)
data "aws_ami" "ubuntu" {
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

# Security group for EC2
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "allow ssh access"

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring server security group"
  }
}

# EC2 Instance
resource "aws_instance" "Monitoring_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  security_groups = [aws_security_group.ec2_security_group.name]
  key_name        = var.key_name

  tags = {
    Name = var.instance_name
  }
}
