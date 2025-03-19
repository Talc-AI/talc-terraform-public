resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.actual_vpc_name}"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

#
# Subnets
#

resource "aws_subnet" "public" {
  count                   = var.availability_zone_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = format("public-%s", local.availability_zones[count.index])
  })
}

resource "aws_subnet" "private" {
  count                   = var.availability_zone_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = format("private-%s", local.availability_zones[count.index])
  })
}

resource "aws_ec2_instance_connect_endpoint" "private" {
  subnet_id = aws_subnet.private[0].id
}

#
# IGW/NAT
#

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.actual_vpc_name}-igw"
  })
}

resource "aws_eip" "nat" {
  count = var.availability_zone_count

  depends_on = [aws_internet_gateway.public]
}

resource "aws_nat_gateway" "this" {
  count         = var.availability_zone_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${local.actual_vpc_name}-nat-${local.availability_zones[count.index]}"
  })
}

#
# Route Tables
#

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.actual_vpc_name}-public-rt"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route_table" "private" {
  count  = var.availability_zone_count
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${local.actual_vpc_name}-private-${local.availability_zones[count.index]}-rt"
  })
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.availability_zone_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

#
# Route Table Associations
#

resource "aws_route_table_association" "private" {
  count          = var.availability_zone_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = var.availability_zone_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
