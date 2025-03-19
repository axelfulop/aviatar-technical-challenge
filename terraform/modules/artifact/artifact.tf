resource "google_artifact_registry_repository" "artifact" {
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
}
