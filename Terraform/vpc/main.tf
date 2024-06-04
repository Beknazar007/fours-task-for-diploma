terraform {
  required_version = ">= 0.12.15"
}

locals {
  len_public_subnets  = length(var.public_subnets_cidr)
  len_private_subnets = length(var.private_subnets_cidr)

}

#######
# VPC #
#######
resource "aws_vpc" "main" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.network_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_hostnames
  enable_dns_hostnames = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.vpc_tags,
    var.tags,
  )
}

##########################
# Default Security Group #
##########################
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main[0].id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = format("default-%s", var.name)
    },
    var.tags,
  )
}

##################
# Public subnets #
##################
resource "aws_subnet" "public" {
  count                   = local.len_public_subnets > 0 ? var.azs : 0
  cidr_block              = element(var.public_subnets_cidr, count.index)
  vpc_id                  = aws_vpc.main[0].id
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format("%s-public", "${var.environment}-${element(var.zones, count.index)}")
    },
    var.public_subnet_tags,
    var.tags,
  )
}


###################
# Private subnets #
###################

resource "aws_subnet" "private" {
  count                   = local.len_private_subnets > 0 ? var.azs : 0
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = var.associate_public_ip

  tags = merge(
    {
      "Name" = format("%s-private", "${var.environment}-${element(var.zones, count.index)}")
    },
    var.private_subnet_tags,
    var.tags,
  )
}


####################
# Internet Gateway #
####################
resource "aws_internet_gateway" "igw" {
  count  = local.len_public_subnets > 0 || var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = merge(
    {
      "Name" = format("%s-igw", var.name)
    },
    var.tags,
  )
}


##############
#NAT Gateway #
##############

resource "aws_eip" "nat" {
  count  = local.len_private_subnets > 0 || var.enable_nat_gateway ? var.azs : 0
  domain = "vpc"

  tags = merge(
    {
      "Name" = format("%s-ip", "${var.environment}-${element(var.zones, count.index)}")
    },
    var.tags,
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway ? var.azs : 0
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = format("%s-nat", "${var.environment}-${element(var.zones, count.index)}")
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.igw]
}

