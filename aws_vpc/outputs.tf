output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "main_route_table_id" {
  value = aws_vpc.this.main_route_table_id
}

output "owner_id" {
  value = aws_vpc.this.owner_id
}

output "internet_gateway_id" {
  value = length(aws_internet_gateway.this.*.id) == 0 ? null : aws_internet_gateway.this[0].id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_route_table_id" {
  value = length(aws_route_table.public.*.id) == 0 ? null : aws_route_table.public[0].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.this.*.id
}


output "nat_gateway_public_ips" {
  value = aws_nat_gateway.this.*.public_ip
}

output "nat_gateway_ptivate_ips" {
  value = aws_nat_gateway.this.*.private_ip
}
