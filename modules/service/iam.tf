resource "aws_iam_role" "service_task_role" {
  name                 = "${var.iam_role_prefix}${var.environment_name}-service-task-role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  permissions_boundary = var.iam_role_permissions_boundary_arn
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name                 = "${var.iam_role_prefix}${var.environment_name}-ecs-task-execution-role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  permissions_boundary = var.iam_role_permissions_boundary_arn
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_policy" "allow_secrets_access" {
  name        = "${var.iam_policy_prefix}${var.environment_name}-allow-secrets-access"
  description = "Policy to allow ECS task execution role to access secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.service_auth_tokens.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_secrets_access_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_secrets_access.arn
}


resource "aws_iam_policy" "allow_invoke_bedrock_models" {
  name        = "${var.iam_policy_prefix}${var.environment_name}-allow-invoke-bedrock-models"
  description = "Policy to allow ECS task execution role to invoke Bedrock models"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:CreateModelInvocationJob",
          "bedrock:GetInferenceProfile",
        ]
        "Resource" = [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:*:*:inference-profile/*",
          "arn:aws:bedrock:*:*:application-inference-profile/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_invoke_bedrock_models_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_invoke_bedrock_models.arn
}
