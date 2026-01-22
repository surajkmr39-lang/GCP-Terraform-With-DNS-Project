# Load Balancer Module Outputs

output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = google_compute_global_forwarding_rule.web_http_forwarding_rule.ip_address
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${google_compute_global_forwarding_rule.web_http_forwarding_rule.ip_address}"
}

output "https_load_balancer_ip" {
  description = "IP address of the HTTPS load balancer"
  value       = google_compute_global_forwarding_rule.web_https_forwarding_rule.ip_address
}

output "backend_service_name" {
  description = "Name of the backend service"
  value       = google_compute_backend_service.web_backend.name
}

output "instance_group_manager_name" {
  description = "Name of the instance group manager"
  value       = length(var.instance_groups) == 0 ? google_compute_region_instance_group_manager.web_igm[0].name : null
}

output "health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.web_health_check.name
}

output "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  value       = google_compute_managed_ssl_certificate.web_ssl_cert.name
}