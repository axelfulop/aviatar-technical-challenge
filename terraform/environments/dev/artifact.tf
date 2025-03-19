module "sensors_artifact"{
    source = "../../modules/artifact"
    location = var.region
    repository_id = "sensors"
    format = "DOCKER"
}
#