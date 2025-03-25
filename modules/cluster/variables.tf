variable "environment_name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
  }
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_instances_min" {
  type    = number
  default = 1
}

variable "cluster_instances_max" {
  type    = number
  default = 1
}

variable "cluster_target_capacity_pct" {
  type    = number
  default = 90
}

variable "instance_type" {
  type    = string
  default = "t4g.2xlarge"
}

variable "instance_storage_gb" {
  type    = number
  default = 30
}

variable "ecs_stop_timeout" {
  type    = string
  default = "1440m"
}

variable "iam_role_prefix" {
  type    = string
  default = ""
}

variable "iam_policy_prefix" {
  type    = string
  default = ""
}

variable "iam_role_permissions_boundary_arn" {
  type    = string
  default = null
}
