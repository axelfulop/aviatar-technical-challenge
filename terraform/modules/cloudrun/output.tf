output "cloud_run_service_urls" {
  value       = { for s, v in google_cloud_run_service.service : s => v.status[0].url }
  description = "The URLs of the deployed Cloud Run services."
}
