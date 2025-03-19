resource "aws_elasticache_serverless_cache" "cache" {
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

