# Firewall Module Outputs

output "firewall_rules" {
  description = "Created firewall rules"
  value = {
    allow_http         = google_compute_firewall.allow_http.name
    allow_https        = google_compute_firewall.allow_https.name
    allow_ssh          = google_compute_firewall.allow_ssh.name
    allow_internal     = google_compute_firewall.allow_internal.name
    allow_health_check = google_compute_firewall.allow_health_check.name
    allow_dns          = google_compute_firewall.allow_dns.name
    allow_egress       = google_compute_firewall.allow_egress.name
    deny_all           = google_compute_firewall.deny_all.name
  }
}