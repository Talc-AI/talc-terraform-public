variable "environment_name" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "tags" {
  type = map(string)
  default = {
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "availability_zone_count" {
  type    = number
  default = 2
}

