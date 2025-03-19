resource "google_service_account" "cloud_run_invoker" {
  for_each     = var.services
  account_id   = "${each.key}-invoker"
  display_name = "${each.key} Invoker"
}

resource "google_cloud_run_service_iam_binding" "cloud_run_invoker_binding" {
  for_each = var.services
  location = each.value.region
  service  = google_cloud_run_service.service[each.key].name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.cloud_run_invoker[each.key].email}"]
}

resource "google_cloud_scheduler_job" "cloud_run_trigger" {
  for_each  = var.services
  name      = "${each.key}-trigger"
  region    = "europe-west3"
  schedule  = each.value.cron_expression
  time_zone = each.value.time_zone

  http_target {
    uri         = "${google_cloud_run_service.service[each.key].status[0].url}/${each.value.scheduler_endpoint}"
    http_method = "GET"
    oidc_token {
      service_account_email = google_service_account.cloud_run_invoker[each.key].email
    }
  }
  depends_on = [google_cloud_run_service.service]
}
