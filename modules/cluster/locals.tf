data "aws_ssm_parameter" "ecs_instance_image" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended"
}

locals {
  cluster_name     = var.environment_name
  ecs_instance_ami = jsondecode(data.aws_ssm_parameter.ecs_instance_image.value)["image_id"]
}
