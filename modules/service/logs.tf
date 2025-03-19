resource "aws_cloudwatch_log_group" "service_logs" {
  name = "/ecs/${var.environment_name}-service"
}
