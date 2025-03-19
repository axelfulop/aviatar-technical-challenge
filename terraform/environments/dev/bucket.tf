module "gcs_path" {
    source = "./../../modules/bucket"
    bucket_name = "dataflow-gcs-path"
    location = "EU"
    force_destroy = true
}

module "gcs_temp" {
    source = "./../../modules/bucket"
    bucket_name = "dataflow-gcs-temp"
    location = "EU"
    force_destroy = true
}