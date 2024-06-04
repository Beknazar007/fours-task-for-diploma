variable "name" {
  description = "Name to be used on all the resources as identifier"
}

variable "csl_subnet_name" {
  description = "List of public subnet name to be created"
  type        = list(string)
  default     = []
}


variable "region" {
  description = "AWS region for deployment"
}

variable "zones" {
  description = "Used availability zones"
  type        = list(string)
}

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC which ensures that EC2 instances launched in this VPC use the EC2 instance tenancy attribute specified when the EC2 instance is launched"
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "associate_public_ip" {
  description = "Enable/disable association of public IP for master ASG and nodes. Default is 'false'."
  default     = false
}

variable "network_cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnets_cidr" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets_cidr" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "topology" {
  description = "Controls network topology for the cluster. public|private. Default is 'private'."
  default     = "private"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  default     = {}
}

variable "azs" {
  description = "A count of availability zones in the region. Default is 2."
  default     = "2"
}

variable "delete_nat" {
  type        = bool
  description = "Set to true if NAT service should be deleted"
  default     = false
}

variable "enable_nat_gateway" {
  type        = bool
  description = "enable nat gateway for private subnets"
  default     = true
}

variable "eks_subnet_name" {
  description = "List of eks subnet name to be created"
  type        = list(string)
  default     = []
}

variable "eks_subnet_cidr" {
  description = "A list of eks subnets inside the VPC"
  type        = list(string)
  default     = []
}




variable "create_internet_gateway" {
  description = "set to true if to create the internet gateway"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Name of the environment in wich to deploy the resources"
  type        = string
}