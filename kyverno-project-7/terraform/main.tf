terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_eks_cluster" "vulnerable_cluster" {
  name     = "my-vulnerable-cluster"
  role_arn = "arn:aws:iam::123456789012:role/eks-cluster-role"

  vpc_config {
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
    
    # Intentional Security Vulnerability: Expose endpoint to public Internet
    # This will be blocked by Kyverno JSON policy
    endpoint_public_access = true 
  }
}