variable "project_id" {
  type = string
}

variable "dataset_id" {
  type = string
}

variable "dataflow_job_name" {
  type = string
}

variable "region" {
  type = string
}

variable "gcs_path" {
  type = string
}

variable "gcs_temp" {
  type = string
}

variable "parameters" {
  type = map(string)
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "machine_type" {
  type    = string
  default = null
}

variable "topic_id" {
  type = string
}
