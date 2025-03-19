resource "google_cloud_run_service" "service" {
  for_each = var.services

  name     = each.key
  location = each.value.region

  template {
    spec {
      dynamic "containers" {
        for_each = each.value.containers
        content {
          image = containers.value.image

          dynamic "env" {
            for_each = containers.value.env
            content {
              name = env.value.name
              dynamic "value_from" {
                for_each = env.value.value_from != null ? [1] : []
                content {
                  dynamic "secret_key_ref" {
                    for_each = [1]
                    content {
                      name = env.value.value_from.secret_key_ref.name
                      key  = env.value.value_from.secret_key_ref.key
                    }
                  }
                }
              }
              value = env.value.value_from == null ? env.value.value : null
            }
          }
          liveness_probe {
            http_get {
              path = "/"
            }
            initial_delay_seconds = 10
            timeout_seconds       = 20
            period_seconds        = 20
          }
        }
      }
      service_account_name = var.create_sa ? google_service_account.service_account[0].email : each.value.sa_member
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_secret_manager_secret_iam_member.secret_cloudrun, google_pubsub_topic_iam_member.topic_cloudrun]
}
