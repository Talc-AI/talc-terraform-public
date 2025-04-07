data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  svcconfig = {
    "auth" : {
      "service_auth_tokens" : {
        "secret_name" : aws_secretsmanager_secret.service_auth_tokens.name
        "jsonpath" : "$.value"
      }
    },
    "dataset" : {
      "dataset_s3_bucket" : aws_s3_bucket.dataset_bucket.bucket
    }
    "database" : null,
    "cache" : {
      "host" : local.cache_endpoint_address
      "port" : local.cache_endpoint_port
      "ssl" : true
    }
    "llm" : var.svcconfig_llm
  }
}
