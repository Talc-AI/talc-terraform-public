resource "aws_cloudwatch_log_group" "service_logs" {
  name = "/ecs/${var.environment_name}-service"
}

resource "aws_cloudwatch_log_group" "service_error_logs" {
  name = "/ecs/${var.environment_name}-service-error"
}

resource "aws_cloudwatch_log_group" "service_sensitive_logs" {
  name = "/ecs/${var.environment_name}-service-sensitive"
}


