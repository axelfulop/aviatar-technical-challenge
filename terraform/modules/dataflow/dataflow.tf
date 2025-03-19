resource "google_bigquery_dataset" "sensor_dataset" {
  dataset_id = var.dataset_id
  project    = var.project_id
}

resource "google_dataflow_job" "sensor_streaming" {
  name                  = var.dataflow_job_name
  project               = var.project_id
  region                = var.region
  template_gcs_path     = var.gcs_path
  temp_gcs_location     = var.gcs_temp
  parameters            = var.parameters
  service_account_email = google_service_account.dataflow_sa.email
  network               = var.network
  subnetwork            = var.subnetwork
  machine_type          = var.machine_type
}
