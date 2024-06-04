output "eks_subnet" {
  value = aws_subnet.eks_subnet[*].id
}


output "vpc_id" {
  value = aws_vpc.main[0].id
}

output "eks_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.eks_subnet.*.cidr_block
}

