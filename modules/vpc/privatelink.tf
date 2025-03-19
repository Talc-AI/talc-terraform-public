locals {
  vpc_private_endpoints = [
    "s3",
    "ecr.dkr",
    "logs",
    "ssm",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "secretsmanager",
  ]
}

resource "aws_vpc_endpoint" "private" {
  count              = length(local.vpc_private_endpoints)
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.${local.vpc_private_endpoints[count.index]}"
  security_group_ids = [aws_security_group.vpce.id]
  vpc_endpoint_type  = "Interface"
}

resource "aws_security_group" "vpce" {
  vpc_id = aws_vpc.this.id
  name   = "${var.environment_name}-vpce"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
