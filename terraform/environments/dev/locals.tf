locals {
  docker_artifact_prefix = "docker.pkg.dev"
  cron_expression        = "*/5 * * * *"
  time_zone              = "Etc/UTC"
  scheduler_endpoint     = "send_report"
  services = {
    "sensor1" = {
      api_key            = var.sensor1_api_key
      region             = "europe-west3"
      name               = "sensor1"
      cron_expression    = local.cron_expression
      time_zone          = local.time_zone
      scheduler_endpoint = local.scheduler_endpoint
      containers = [{
        image = "${var.region}-${local.docker_artifact_prefix}/${var.project_id}/${module.sensors_artifact.name}/sensor1:latest"
        env = [
          { name = "TOPIC_PATH",  value_from = { secret_key_ref = { name = "TOPIC_ID", key = "latest" } } },
          { name = "SENSOR_ID", value = "sensor-1" },
          { name = "API_KEY", value_from = { secret_key_ref = { name = "SENSOR1_API_KEY", key = "latest" } } }
        ]
      }]
    },
    "sensor2" = {
      api_key = var.sensor2_api_key
      region  = "europe-west4"
      name    = "sensor2"
      cron_expression    = local.cron_expression
      time_zone          = local.time_zone
      scheduler_endpoint = local.scheduler_endpoint
      containers = [{
        image = "${var.region}-${local.docker_artifact_prefix}/${var.project_id}/${module.sensors_artifact.name}/sensor2:latest"
        env = [
          { name = "TOPIC_PATH",  value_from = { secret_key_ref = { name = "TOPIC_ID", key = "latest" } } },
          { name = "SENSOR_ID", value = "sensor-2" },
          { name = "API_KEY", value_from = { secret_key_ref = { name = "SENSOR2_API_KEY", key = "latest" } } }
        ]
      }]
    }
  }
}
