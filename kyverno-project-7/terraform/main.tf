terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "ap-southeast-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "vulnerable_sg" {
  name        = "vulnerable-ssh-sg"
  description = "Security group allowing public SSH access"
  vpc_id      = aws_vpc.main_vpc.id

  # Intentional Security Vulnerability: Expose SSH (port 22) to the entire Internet
  ingress {
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
}

resource "aws_instance" "vulnerable_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Dummy AMI for testing plan
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]

  tags = {
    Name = "vulnerable-ec2-instance"
  }
}