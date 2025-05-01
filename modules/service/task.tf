resource "aws_ecs_service" "service" {
  # do not create if deployment revision is unset
  count = var.deploy_tag == null ? 0 : 1

  name                    = "${var.environment_name}-service"
  cluster                 = var.ecs_cluster_id
  task_definition         = aws_ecs_task_definition.service_task[0].arn
  desired_count           = var.deploy_task_count
  enable_ecs_managed_tags = true

  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider_name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service_target.arn
    container_name   = "api-service"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "service_task" {
  # do not create if deployment revision is unset
  count = var.deploy_tag == null ? 0 : 1

  family             = "${var.environment_name}-service"
  network_mode       = "bridge"
  task_role_arn      = aws_iam_role.service_task_role.arn
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  container_definitions = jsonencode([
    {
      name = "api-service"
      image = format(
        "%s.dkr.ecr.%s.amazonaws.com/%s:%s",
        var.deploy_repo_account,
        var.region,
        var.deploy_image_name,
        var.deploy_tag
      )
      environment = [
        {
          name  = "SVCCONFIG_DATA"
          value = yamlencode(local.svcconfig)
        },
        {
          name = "AWS_REGION"
          value = var.region
        }
      ]
      memoryReservation = var.service_memory_mb
      essential         = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver : "awslogs",
        options : {
          awslogs-group : aws_cloudwatch_log_group.service_logs.name,
          awslogs-region : var.region,
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])

  depends_on = [aws_cloudwatch_log_group.service_logs]
}
