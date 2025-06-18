variable "environment_name" {
  type = string
}

#
# Cache configuration
#

variable "cache_serverless" {
  type    = bool
  default = true
}

# Severless-only

variable "cache_max_size_gb" {
  type    = number
  default = 10 # if changed, update the check below
}

locals {
  cache_max_size_gb_check = var.cache_serverless ? (
    var.cache_max_size_gb > 0 ? true : error("cache_max_size_gb must be greater than 0 when cache_serverless is true")
    ) : (
    (var.cache_max_size_gb == null || var.cache_max_size_gb == 10) ? true : error("cache_max_size_gb must be unset when cache_serverless is false")
  )
}

variable "cache_max_ecpu_per_second" {
  type    = number
  default = 5000 # if changed, update the check below
}

locals {
  cache_max_ecpu_per_second_check = var.cache_serverless ? (
    var.cache_max_ecpu_per_second > 0 ? true : error("cache_max_ecpu_per_second must be greater than 0 when cache_serverless is true")
    ) : (
    (var.cache_max_ecpu_per_second == null || var.cache_max_ecpu_per_second == 5000) ? true : error("cache_max_ecpu_per_second must be unset when cache_serverless is false")
  )
}

# Instance-only

variable "cache_instance_type" {
  type    = string
  default = "cache.m7g.xlarge" # if changed, update the check below
}

locals {
  cache_instance_type_check = var.cache_serverless ? (
    var.cache_instance_type == null || var.cache_instance_type == "cache.m7g.xlarge" ? true : error("cache_instance_type must be unset when cache_serverless is true")
    ) : (
    (var.cache_instance_type == null ? error("cache_instance_type must be set when cache_serverless is false") : true)
  )
}

#
# Other variables
#

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

variable "default_iam_role_permissions_boundary_arn" {
  type    = string
  default = null
}

variable "service_task_role_permissions_boundary_arn" {
  type    = string
  default = null
}

variable "secrets_manager_prefix" {
  type    = string
  default = ""
}

variable "default_iam_role_prefix" {
  type    = string
  default = ""
}

variable "service_task_role_prefix" {
  type    = string
  default = ""
}

variable "iam_policy_prefix" {
  type    = string
  default = ""
}

variable "dynamodb_table_prefix" {
  type    = string
  default = ""
}

variable "s3_bucket_prefix" {
  type    = string
  default = ""
}

variable "s3_file_storage_lifecycle_expiration_days" {
  type    = number
  default = 7
}
