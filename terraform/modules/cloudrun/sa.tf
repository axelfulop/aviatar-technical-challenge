resource "google_service_account" "service_account" {
  count        = var.create_sa ? 1 : 0
  account_id   = var.sa_name
  display_name = var.sa_name
}

resource "google_pubsub_topic_iam_member" "topic_cloudrun" {
  count  = var.create_sa ? 1 : 0
  topic  = var.topic_id
  role   = "roles/pubsub.publisher"
  member = var.create_sa ? google_service_account.service_account[0].member : var.sa_member

  depends_on = [google_service_account.service_account]
}

resource "google_secret_manager_secret_iam_member" "secret_cloudrun" {
  for_each  = length(var.secrets_map) > 0 ? var.secrets_map : {}
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = var.create_sa ? google_service_account.service_account[0].member : var.sa_member

  depends_on = [google_service_account.service_account]
}
