terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.70.0"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "terraform-dev"
}


# Retrieve available AWS availability zones

data "aws_availability_zones" "available" {
  state = "available"
}

# Display available availability zones

output "available_availability_zones" {
  description = "Available AWS availability zones"
  value       = data.aws_availability_zones.available.names
}


# Deploy the reusable network module
module "network" {
  source = "./modules/network"

  name               = "nisa-terraform-dev"
  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  tags = {
    Project     = "terraform-aws-infrastructure"
    Environment = "dev"
    Owner       = "NISA Technology"
    ManagedBy   = "Terraform"
  }
}

# Display network outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}
