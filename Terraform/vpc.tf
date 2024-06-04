terraform {
  required_providers {
    aws = {
      version = "=5.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source                  = "./vpc"
  name                    = var.vpc_name
  region                  = var.aws_region
  environment             = var.environment
  network_cidr            = var.vpc_network_cidr
  eks_subnet_name         = ["eks-primary"]
  eks_subnet_cidr         = ["${cidrsubnet(var.vpc_network_cidr, 4, 5)}", "${cidrsubnet(var.vpc_network_cidr, 4, 13)}"]
  public_subnets_cidr     = ["${cidrsubnet(var.vpc_network_cidr, 4, 7)}", "${cidrsubnet(var.vpc_network_cidr, 4, 15)}"]
  zones                   = var.resource_availability_zones
  azs                     = length(var.resource_availability_zones)
  enable_nat_gateway      = true
  create_internet_gateway = true

}
