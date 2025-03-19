output "secrets" {
  value = {
    for k, v in google_secret_manager_secret.secret : k => {
      secret_id = v.secret_id
    }
  }
}
