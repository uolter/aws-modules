provider "aws" {
  version = "2.62.0"
  region  = var.aws_region
}

# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  instance_tenancy                 = var.instance_tenancy
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge({
    Name        = "${var.vpc_name}-vpc"
    Environment = var.environment
  }, var.tags)
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count  = var.enable_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name        = "${var.vpc_name}-${var.environment}-igw"
    Environment = var.environment
  }, var.tags)
}

# Public Subnet
resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({
    Name        = "${var.vpc_name}-public-${count.index + 1}"
    Environment = var.environment
  }, var.tags)
}

# Route table: attach Internet Gateway
resource "aws_route_table" "public" {
  count  = length(aws_internet_gateway.this.*.id)
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[count.index].id
  }

  tags = merge({
    Name        = "${var.vpc_name}-public-rt"
    Environment = var.environment
  }, var.tags)
}

# Route table association with public subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_internet_gateway.this.*.id) == 0 ? 0 : length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# Private Subnet
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({
    Name        = "${var.vpc_name}-private-${count.index + 1}"
    Environment = var.environment
  }, var.tags)
}


# Nat gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.azs) : 0

  tags = merge({
    Name        = "${var.vpc_name}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }, var.tags)
}

resource "aws_nat_gateway" "this" {
  count         = length(aws_eip.nat.*.id)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge({
    Name        = "${var.vpc_name}-ngw-${count.index + 1}"
    Environment = var.environment
  }, var.tags)
}

# Route table: nat Gateway
resource "aws_route_table" "private" {
  count  = length(aws_nat_gateway.this.*.id)
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge({
    Name        = "${var.vpc_name}-private-rt-${count.index + 1}"
    Environment = var.environment
  }, var.tags)
}

# Note: a subnet can be associated to only one nat gateway instance
resource "aws_route_table_association" "private" {
  count          = length(aws_route_table.private.*.id)
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}
