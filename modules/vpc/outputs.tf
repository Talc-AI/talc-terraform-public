output "vpc_id" {
  value = aws_vpc.this.id
}

output "region" {
  value = var.region
}

output "availability_zones" {
  value = local.availability_zones
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "igw_id" {
  value = aws_internet_gateway.public.id
}
