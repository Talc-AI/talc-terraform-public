# This file is auto-generated. Do not edit.


resource "aws_dynamodb_table" "extraction_job" {
  name         = "${var.dynamodb_table_prefix}${var.environment_name}extraction_job"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "job_id"


  attribute {
    name = "job_id"
    type = "S"
  }

}


resource "aws_dynamodb_table" "async_task" {
  name         = "${var.dynamodb_table_prefix}${var.environment_name}async_task"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "task_id"


  attribute {
    name = "task_id"
    type = "S"
  }

}


resource "aws_dynamodb_table" "async_task_args" {
  name         = "${var.dynamodb_table_prefix}${var.environment_name}async_task_args"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "task_id"


  attribute {
    name = "task_id"
    type = "S"
  }

}


resource "aws_dynamodb_table" "async_task_result" {
  name         = "${var.dynamodb_table_prefix}${var.environment_name}async_task_result"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "task_id"


  attribute {
    name = "task_id"
    type = "S"
  }

}


resource "aws_dynamodb_table" "execution_plan" {
  name         = "${var.dynamodb_table_prefix}${var.environment_name}execution_plan"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "plan_id"


  attribute {
    name = "plan_id"
    type = "S"
  }

}
