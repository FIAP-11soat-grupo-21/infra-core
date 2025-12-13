output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.subnet_private[*].id
}

output "public_subnet" {
  value = aws_subnet.subnet_public[0].id
}

output "cdir_block" {
  value = aws_vpc.main.cidr_block
}