resource "aws_secretsmanager_secret" "service_auth_tokens" {
  name = "${var.secrets_manager_prefix}talc/${var.deployment_environment}/medservice_auth_tokens"
}
