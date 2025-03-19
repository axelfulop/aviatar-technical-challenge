resource "google_pubsub_topic" "topic" {
  name                       = var.name
  labels                     = var.labels
  message_retention_duration = var.message_retention_duration
}

resource "google_pubsub_subscription" "sub" {
  count = var.create_sub ? 1 : 0
  name  = var.sub_name
  topic = google_pubsub_topic.topic.id

  ack_deadline_seconds = 20

  labels = var.sub_labels
}
