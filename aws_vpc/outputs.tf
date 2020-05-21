output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "arn" {
  value = aws_vpc.vpc.arn
}

output "main_route_table_id" {
  value = aws_vpc.vpc.main_route_table_id
}

output "owner_id" {
  value = aws_vpc.vpc.owner_id
}

output "internet_gateway_id" {
  value = length(aws_internet_gateway.internet_gateway.*.id) == 0 ? null : aws_internet_gateway.internet_gateway[0].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "public_route_table_id" {
  value = length(aws_route_table.public_route_table.*.id) == 0 ? null : aws_route_table.public_route_table[0].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat_gateway.*.id
}


output "nat_gateway_public_ips" {
  value = aws_nat_gateway.nat_gateway.*.public_ip
}

output "nat_gateway_ptivate_ips" {
  value = aws_nat_gateway.nat_gateway.*.private_ip
}

