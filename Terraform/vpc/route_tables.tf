#################
# Publiс routes #
#################

resource "aws_route_table" "public" {
  count  = local.len_public_subnets > 0 ? var.azs : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = merge(
    {
      "Name" = format("%s-public", "${var.environment}-${element(var.zones, count.index)}")
    },
    var.tags,
  )
}

resource "aws_route_table_association" "public" {
  count          = local.len_public_subnets > 0 ? var.azs : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

##################
# Private routes #
##################

resource "aws_route" "main" {
  count                  = local.len_private_subnets > 0 ? var.azs : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = local.len_private_subnets > 0 ? var.azs : 0
  vpc_id = aws_vpc.main[0].id
  tags = merge(
    {
      "Name" = format("%s-private", "${var.environment}-${element(var.zones, count.index)}")
    },
    var.tags,
  )
}

resource "aws_route_table_association" "private" {
  count          = local.len_private_subnets > 0 ? var.azs : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

