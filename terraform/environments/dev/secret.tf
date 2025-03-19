module "sensors_api_key" {
  source  = "./../../modules/secretsmanager"
  secrets = {
    for k, v in local.services : upper(format("%s_%s", v.name, "API_KEY")) => v.api_key
  }
}

module "topic_id" {
  source = "../../modules/secretsmanager"
  secrets = {
    TOPIC_ID = module.sensors_topic.id
  }

  depends_on = [ module.sensors_topic ]
}#