resource "aws_lb" "service" {
  name               = "${var.environment_name}-service"
  internal           = var.use_internal_lb
  load_balancer_type = "application"
  idle_timeout       = 600
  security_groups    = [aws_security_group.service.id]
  subnets            = var.load_balancer_subnet_ids

  tags = merge(var.tags,
    {
      Name = "${var.environment_name}-service"
    }
  )
}

resource "aws_lb_listener" "service_listener" {
  load_balancer_arn = aws_lb.service.arn
  port              = var.certificate_arn == null ? 80 : 443
  protocol          = var.certificate_arn == null ? "HTTP" : "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target.arn
  }

  tags = merge(var.tags,
    {
      Name = "${var.environment_name}-service"
    }
  )
}

resource "aws_lb_listener" "service_listener_redirect" {
  count = var.certificate_arn == null ? 0 : 1

  load_balancer_arn = aws_lb.service.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.tags,
    {
      Name = "${var.environment_name}-service-redirect"
    }
  )
}

resource "aws_lb_target_group" "service_target" {
  name        = "${var.environment_name}-service-bridge"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path = "/docs"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags,
    {
      Name = "${var.environment_name}-service-bridge"
    }
  )
}


resource "aws_security_group" "service" {
  name   = "${var.environment_name}-lb"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
