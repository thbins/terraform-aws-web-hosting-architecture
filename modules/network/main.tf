locals {
  # AZ와 각 서브넷 CIDR을 인덱스로 묶어서 다룬다
  az_map = {
    for idx, az in var.azs :
    idx => {
      az          = az
      suffix      = regex("([a-z])$", az)[0]
      cidr_pub    = var.public_subnets[idx]
      cidr_priv   = var.web_subnets[idx]
      cidr_intra  = var.app_subnets[idx]
      cidr_db     = var.db_subnets[idx]
    }
  }
}

# VPC / IGW
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.name}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  for_each                = local.az_map
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr_pub
  map_public_ip_on_launch = true
  tags = { Name = "${var.name}-pub-${each.value.suffix}" }
}

resource "aws_subnet" "web_subnet" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_priv
  tags = { Name = "${var.name}-web-${each.value.suffix}" }
}

resource "aws_subnet" "app_subnet" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_intra
  tags = { Name = "${var.name}-app-${each.value.suffix}" }
}

resource "aws_subnet" "db_subnet" {
  for_each          = local.az_map
  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_db
  tags = { Name = "${var.name}-db-${each.value.suffix}" }
}

# Route tables (라벨/참조 정합)
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-rtb-public" }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rtb.id
}

# NAT per AZ
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? local.az_map : {}
  domain   = "vpc"
  tags     = { Name = "${var.name}-eip-nat-${each.value.suffix}" }
}

resource "aws_nat_gateway" "this" {
  for_each      = var.enable_nat_gateway ? local.az_map : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id
  tags          = { Name = "${var.name}-nat-${each.value.suffix}" }
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_route_table" "web_rtb" {
  for_each = local.az_map
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-rtb-web-${each.value.suffix}" }
}

resource "aws_route" "web_nat" {
  for_each               = var.enable_nat_gateway ? local.az_map : {}
  route_table_id         = aws_route_table.web_rtb[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "web_assoc" {
  for_each       = local.az_map
  subnet_id      = aws_subnet.web_subnet[each.key].id
  route_table_id = aws_route_table.web_rtb[each.key].id
}

resource "aws_route_table" "app_rtb" {
  for_each = local.az_map
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-rtb-app-${each.value.suffix}" }
}

resource "aws_route_table_association" "app_assoc" {
  for_each       = local.az_map
  subnet_id      = aws_subnet.app_subnet[each.key].id
  route_table_id = aws_route_table.app_rtb[each.key].id
}

resource "aws_route_table" "db_rtb" {
  for_each = local.az_map
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name}-rtb-db-${each.value.suffix}" }
}

resource "aws_route_table_association" "db_assoc" {
  for_each       = local.az_map
  subnet_id      = aws_subnet.db_subnet[each.key].id
  route_table_id = aws_route_table.db_rtb[each.key].id
}