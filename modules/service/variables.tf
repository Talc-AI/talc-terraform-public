variable "environment_name" {
  type = string
}

variable "cache_max_size_gb" {
  type    = number
  default = 10
}

variable "cache_max_ecpu_per_second" {
  type    = number
  default = 5000
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

variable "use_internal_lb" {
  type = bool
}

variable "availability_zones" {
  type = list(string)
}

variable "load_balancer_subnet_ids" {
  type = list(string)
}

variable "service_subnet_ids" {
  type = list(string)
}

variable "service_memory_mb" {
  type    = number
  default = 8192
}

variable "deploy_image_name" {
  type = string
}

variable "deploy_tag" {
  type    = string
  default = null
}

variable "deploy_repo_account" {
  type = string
}

variable "certificate_arn" {
  type     = string
  nullable = true
}

variable "deploy_task_count" {
  type    = number
  default = 1
}

variable "ecs_cluster_id" {
  type = string
}

variable "ecs_capacity_provider_name" {
  type = string
}

variable "svcconfig_llm" {
  type = any
}

variable "iam_role_permissions_boundary_arn" {
  type    = string
  default = null
}

variable "secrets_manager_prefix" {
  type    = string
  default = ""
}

variable "iam_role_prefix" {
  type    = string
  default = ""
}
