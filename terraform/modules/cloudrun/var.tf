variable "services" {
  type = map(object({
    region             = string
    cron_expression    = string
    time_zone          = string
    scheduler_endpoint = string
    api_key            = string
    name               = string
    containers = list(object({
      image = string
      env = list(object({
        name  = string
        value = optional(string)
        value_from = optional(object({
          secret_key_ref = object({
            name = string
            key  = string
          })
        }))
      }))
    }))
  }))
  default = {}
}

variable "sa_name" {
  type = string
}

variable "create_sa" {
  type    = bool
  default = false
}

variable "project_id" {
  type = string
}

variable "topic_id" {
  type    = string
  default = null
}

variable "sa_member" {
  type    = string
  default = null
}

variable "secrets_map" {
  type    = map(object({ secret_id = string }))
  default = {}
}
