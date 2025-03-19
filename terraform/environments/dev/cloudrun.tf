module "sensors_service" {
  source     = "./../../modules/cloudrun"
  services   = local.services
  create_sa  = true
  project_id = var.project_id
  topic_id   = module.sensors_topic.id
  sa_name    = "sensors" 
  secrets_map =  merge(module.sensors_api_key.secrets, module.topic_id.secrets)

  depends_on = [module.sensors_artifact, module.sensors_topic, module.sensors_api_key, module.topic_id]
}
#