# IAM Module Outputs

output "service_accounts" {
  description = "Created service accounts"
  value = {
    compute_sa = {
      email = google_service_account.compute_sa.email
      name  = google_service_account.compute_sa.name
    }
    dns_sa = {
      email = google_service_account.dns_sa.email
      name  = google_service_account.dns_sa.name
    }
    lb_sa = {
      email = google_service_account.lb_sa.email
      name  = google_service_account.lb_sa.name
    }
  }
}

output "custom_roles" {
  description = "Created custom IAM roles"
  value = {
    dns_manager = google_project_iam_custom_role.dns_manager.name
  }
}

output "service_account_keys" {
  description = "Service account keys (base64 encoded)"
  value = {
    compute_sa_key = google_service_account_key.compute_sa_key.private_key
    dns_sa_key     = google_service_account_key.dns_sa_key.private_key
  }
  sensitive = true
}