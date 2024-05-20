variable "prefix" {
  type        = string
  description = "prefix used as name of infra"
}

variable "region" {
  type        = string
  description = "aws region where is deploying the infrastructure "
}

variable "endpoint_register" {
  type        = string
  description = "value"

}

variable "endpoint_verify" {
  type        = string
  description = "value"
}

variable "html_files" {
  type = list(string)
}