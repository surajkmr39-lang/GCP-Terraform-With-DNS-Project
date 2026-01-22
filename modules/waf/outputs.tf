# WAF Module Outputs

output "security_policy_name" {
  description = "Name of the main Cloud Armor security policy"
  value       = google_compute_security_policy.waf_policy.name
}

output "security_policy_id" {
  description = "ID of the main Cloud Armor security policy"
  value       = google_compute_security_policy.waf_policy.id
}

output "api_security_policy_name" {
  description = "Name of the API Cloud Armor security policy"
  value       = google_compute_security_policy.api_waf_policy.name
}

output "security_policy_fingerprint" {
  description = "Fingerprint of the security policy"
  value       = google_compute_security_policy.waf_policy.fingerprint
}