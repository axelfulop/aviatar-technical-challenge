variable "name" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "message_retention_duration" {
  type    = string
  default = "604800s"
}

variable "create_sub" {
  type    = bool
  default = false
}

variable "sub_labels" {
  type    = map(string)
  default = {}
}

variable "sub_name" {
  type    = string
  default = null
}
