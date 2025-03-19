resource "google_service_account" "dataflow_sa" {
  account_id   = "dataflow-sa"
  display_name = "Dataflow Service Account"
}

resource "google_pubsub_topic_iam_member" "dataflow_topic" {
  topic  = var.topic_id
  role   = "roles/pubsub.subscriber"
  member = "serviceAccount:${google_service_account.dataflow_sa.email}"

  depends_on = [google_service_account.dataflow_sa]
}