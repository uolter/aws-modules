provider "aws" {
  version = "2.62.0"
  region  = var.aws_region
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = {
    Name        = var.vpc_name
    Owner       = var.owner
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  count  = var.enable_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = local.internet_gateway_name
    Owner       = var.owner
    Environment = var.environment
  }
}

# Public Subnet
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.vpc_name}-public-${count.index + 1}"
    Owner       = var.owner
    Environment = var.environment
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_route_table" {
  count  = length(aws_internet_gateway.internet_gateway.*.id)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway[count.index].id
  }

  tags = {
    Name        = "${var.vpc_name}-public-route-table"
    Owner       = var.owner
    Environment = var.environment
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "route_table_association" {
  count          = length(aws_internet_gateway.internet_gateway.*.id) == 0 ? 0 : length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_route_table[0].id
}

# Private Subnet
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.vpc_name}-private-${count.index + 1}"
    Owner       = var.owner
    Environment = var.environment
  }
}


# Nat gateway 
resource "aws_eip" "nat_eip" {
  count = var.enable_nat_gateway ? length(var.azs) : 0

  tags = {
    Name        = "${var.vpc_name}-nat-eip-${count.index + 1}"
    Owner       = var.owner
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(aws_eip.nat_eip.*.id)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name        = "${var.vpc_name}-ngw-${count.index + 1}"
    Owner       = var.owner
    Environment = var.environment
  }
}

# Route table: nat Gateway 
resource "aws_route_table" "nat_route_table" {
  count  = length(aws_nat_gateway.nat_gateway.*.id)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name        = "${var.vpc_name}-nat-route-table"
    Owner       = var.owner
    Environment = var.environment
  }
}

# Note: a subnet can be associated to only one nat gateway instance
resource "aws_route_table_association" "table_association" {
  count          = length(aws_route_table.nat_route_table.*.id)
  route_table_id = aws_route_table.nat_route_table[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}