resource "aws_secretsmanager_secret" "service_auth_tokens" {
  name = "${var.secrets_manager_prefix}talc/prod/medservice_auth_tokens"
}
