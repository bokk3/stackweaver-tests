variable "AWS_PROFILE" {
  type    = string
  default = "default"
}

variable "AWS_REGION" {
  type    = string
  default = "us-east-1"
}

variable "AWS_ACCESS_KEY_ID" {
  type    = string
  default = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type    = string
  default = ""
}

variable "AWS_ASSUME_ROLE_ARN" {
  type    = string
  default = null
}