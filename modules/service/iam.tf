#
# Service Task Role
#

resource "aws_iam_role" "service_task_role" {
  name                 = "${try(coalesce(var.service_task_role_prefix, var.default_iam_role_prefix), "")}${var.environment_name}-service-task-role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  permissions_boundary = try(coalesce(var.service_task_role_permissions_boundary_arn, var.default_iam_role_permissions_boundary_arn), null)
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

resource "aws_iam_role_policy_attachment" "allow_secrets_access_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_secrets_access.arn
}

resource "aws_iam_role_policy_attachment" "allow_invoke_bedrock_models_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_invoke_bedrock_models.arn
}

resource "aws_iam_role_policy_attachment" "allow_s3_storage_access_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_s3_storage_access.arn
}

resource "aws_iam_role_policy_attachment" "allow_dynamodb_access_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "allow_cw_agent_write_sensitive_error_attachment" {
  role       = aws_iam_role.service_task_role.name
  policy_arn = aws_iam_policy.allow_cw_agent_write_sensitive_error.arn
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

resource "aws_iam_policy" "allow_s3_storage_access" {
  name        = "${var.iam_policy_prefix}${var.environment_name}-allow-s3-storage-access"
  description = "Policy to allow ECS task execution role to access S3 storage for uploads and results"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.file_storage.arn}/*",
          aws_s3_bucket.file_storage.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "allow_dynamodb_access" {
  name        = "${var.iam_policy_prefix}${var.environment_name}-allow-dynamodb-access"
  description = "Policy to allow ECS task execution role to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_prefix}${var.environment_name}*"
      }
    ]
  })
}

resource "aws_iam_policy" "allow_cw_agent_write_sensitive_error" {
  name        = "${var.iam_policy_prefix}${var.environment_name}-allow-cw-agent-write-sensitive-error"
  description = "Let cw-agent put logs to the error & sensitive groups"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "${aws_cloudwatch_log_group.service_error_logs.arn}:*",
          "${aws_cloudwatch_log_group.service_sensitive_logs.arn}:*"
        ]
      }
    ]
  })
}

#
# ECS Task Execution Role
#

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name                 = "${var.default_iam_role_prefix}${var.environment_name}-ecs-task-execution-role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  permissions_boundary = var.default_iam_role_permissions_boundary_arn
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy_attachment" "allow_ecr_pull_attachment" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_policy.allow_ecr_pull.arn
}


resource "aws_iam_policy" "allow_ecr_pull" {
  name        = "${var.iam_policy_prefix}${var.environment_name}-allow-ecr-pull"
  description = "Policy to allow ECS task execution role to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action : "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:*:${var.deploy_repo_account}:repository/${var.deploy_image_name}"
      }
    ]
  })
}
