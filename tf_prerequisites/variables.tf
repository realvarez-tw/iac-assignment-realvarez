variable "prefix" {
  type        = string
  description = "prefix used as name of infra"
  default     = "iac-assignment-realvarez"
}

variable "region" {
  type        = string
  description = "aws region where is deploying the infrastructure"
  default     = "sa-east-1"
}

variable "repo_name" {
  type    = string
  default = "realvarez-tw/iac-assignment-realvarez"
}