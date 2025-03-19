locals {
  actual_vpc_name = var.vpc_name != null ? var.vpc_name : var.environment_name

  common_tags = merge(
    var.tags,
    {
      Environment = var.environment_name
    }
  )

  _sorted_azs        = sort(data.aws_availability_zones.available.names)
  availability_zones = slice(local._sorted_azs, 0, var.availability_zone_count)

  public_subnet_cidrs = [
    for i in range(var.availability_zone_count) : cidrsubnet(var.vpc_cidr, 8, i * 2)
  ]

  private_subnet_cidrs = [
    for i in range(var.availability_zone_count) : cidrsubnet(var.vpc_cidr, 8, i * 2 + 1)
  ]
}
