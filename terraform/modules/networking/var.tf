variable "name" {
  type = string
}

variable "auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "cidr_range" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "region" {
  type    = string
  default = null
}

variable "private_ip_google_access" {
  type    = bool
  default = true
}

variable "firewall_name" {
  type = string
}

variable "firewall_rules" {
  type = list(object({
    protocol = string
    ports    = optional(list(string))
  }))
}

variable "source_ranges" {
  type        = list(string)
}

variable "project_id" {
  type = string
}
