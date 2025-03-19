resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.cluster_name
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                = var.environment_name
  vpc_zone_identifier = var.subnet_ids
  max_size            = var.cluster_instances_max
  min_size            = var.cluster_instances_min

  wait_for_elb_capacity = "0"

  launch_template {
    id      = aws_launch_template.ecs_host_template.id
    version = "$Latest"
  }

  # This tag is required to let ECS control scaling.
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_cluster" {
  name = format("cp-%s", local.cluster_name)

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_cluster.arn

    managed_scaling {
      maximum_scaling_step_size = var.cluster_instances_max
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.cluster_target_capacity_pct
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster" {
  cluster_name = local.cluster_name

  capacity_providers = [aws_ecs_capacity_provider.ecs_cluster.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_cluster.name
  }
}
