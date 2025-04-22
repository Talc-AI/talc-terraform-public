resource "aws_elasticache_serverless_cache" "cache" {
  count = var.cache_serverless ? 1 : 0

  engine = "redis"
  name   = "${var.environment_name}-cache"
  cache_usage_limits {
    data_storage {
      maximum = var.cache_max_size_gb
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = var.cache_max_ecpu_per_second
    }
  }
  daily_snapshot_time      = "04:00"
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  security_group_ids       = [aws_security_group.cache.id]
  subnet_ids               = var.service_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment_name}-cache"
    }
  )
}

resource "aws_elasticache_replication_group" "cache" {
  count = var.cache_serverless ? 0 : 1

  replication_group_id = "${var.environment_name}-cache"
  description          = "${var.environment_name}-cache"

  engine                   = "redis"
  engine_version           = "7.1"
  node_type                = var.cache_instance_type
  security_group_ids       = [aws_security_group.cache.id]
  parameter_group_name     = "default.redis7"
  port                     = 6379
  snapshot_retention_limit = 1
  snapshot_window          = "04:00-05:00"
  subnet_group_name        = aws_elasticache_subnet_group.cache[0].name

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  transit_encryption_mode = "preferred"

  multi_az_enabled           = false
  automatic_failover_enabled = false
  num_cache_clusters         = 1

  apply_immediately = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment_name}-cache"
    }
  )
}

resource "aws_elasticache_subnet_group" "cache" {
  count = var.cache_serverless ? 0 : 1

  name       = "${var.environment_name}-cache"
  subnet_ids = var.service_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment_name}-cache"
    }
  )
}

locals {
  cache_endpoint_address = var.cache_serverless ? aws_elasticache_serverless_cache.cache[0].endpoint[0].address : aws_elasticache_replication_group.cache[0].primary_endpoint_address
  cache_endpoint_port    = var.cache_serverless ? aws_elasticache_serverless_cache.cache[0].endpoint[0].port : aws_elasticache_replication_group.cache[0].port
}

resource "aws_security_group" "cache" {
  name   = "${var.environment_name}-cache"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

