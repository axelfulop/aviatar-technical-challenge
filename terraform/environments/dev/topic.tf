module "sensors_topic" {
  source     = "./../../modules/topic"
  name       = "sensors"
  create_sub = true
  sub_name   = "sensors_sub"
  depends_on = [module.sensors_artifact]
}
