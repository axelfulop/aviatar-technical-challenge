variable "project_id" {
  type = string
}
variable "region" {
  type = string
}

variable "environment" {
  type = string
}
variable "sensor1_api_key" {
  type      = string
  sensitive = true
}

variable "sensor2_api_key" {
  type      = string
  sensitive = true
}

variable "create_cloudrun_sa" {
  type    = bool
  default = true
}
