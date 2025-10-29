resource "aws_security_group" "ecs_host" {
  name   = "${var.environment_name}-ecs-host"
  vpc_id = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "ecs_host_ingress" {
  security_group_id = aws_security_group.ecs_host.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_host_egress" {
  security_group_id = aws_security_group.ecs_host.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_launch_template" "ecs_host_template" {
  name_prefix   = "${var.environment_name}-ecs-host"
  image_id      = local.ecs_instance_ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ecs_host.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.instance_storage_gb
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.environment_name}-cluster"
    })
  }

  # See https://github.com/aws/amazon-ecs-agent/blob/master/README.md
  # for documentation of ECS agent config parameters.
  user_data = base64encode(<<-EOT
    #!/bin/bash

    # Install the CloudWatch agent
    yum install -y amazon-cloudwatch-agent

    # Write CloudWatch agent configuration
    cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/ecs/ecs-agent.log",
                "log_group_name": "${aws_cloudwatch_log_group.ecs_agent_log_group.name}",
                "log_stream_name": "{instance_id}"
              }
            ]
          }
        }
      }
    }
    EOF

    # Start the CloudWatch agent with the new configuration
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

    echo "ECS_CLUSTER=${local.cluster_name}" >> /etc/ecs/ecs.config
    echo "ECS_CONTAINER_STOP_TIMEOUT=${var.ecs_stop_timeout}" >> /etc/ecs/ecs.config
    echo "ECS_IMAGE_PULL_BEHAVIOR=once" >> /etc/ecs/ecs.config
    EOT
  )
}

resource "aws_cloudwatch_log_group" "ecs_agent_log_group" {
  name = "/ecs/ecs-agent"
}
