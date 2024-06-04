######################
## Public Subnets  ##
######################

locals {
  len_eks_subnets = length(var.eks_subnet_cidr)
}

resource "aws_subnet" "eks_subnet" {
  count                   = local.len_eks_subnets > 0 ? var.azs : 0
  cidr_block              = element(var.eks_subnet_cidr, count.index)
  vpc_id                  = aws_vpc.main[0].id
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = var.associate_public_ip
  tags = merge(
    {
      "Name" = format("%s-private", "${var.environment}-${element(var.zones, count.index)}-${var.eks_subnet_name[0]}")
    },
    var.private_subnet_tags,
    var.tags,
  )
}

#################
## ROUTE TABLE ##
#################


resource "aws_route_table" "eks_route_table" {
  count  = local.len_eks_subnets > 0 ? var.azs : 0
  vpc_id = aws_vpc.main[0].id
  tags = merge(
    {
      "Name" = format("%s-private", "${var.environment}-${element(var.zones, count.index)}-${var.eks_subnet_name[0]}")
    },
    var.tags,
  )
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }
}

resource "aws_route_table_association" "eks_route_association" {
  count          = local.len_eks_subnets > 0 ? var.azs : 0
  subnet_id      = element(aws_subnet.eks_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.eks_route_table.*.id, count.index)
}