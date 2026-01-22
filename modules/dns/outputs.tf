# DNS Module Outputs

output "private_zone_name" {
  description = "Name of the private DNS zone"
  value       = google_dns_managed_zone.private_zone.name
}

output "private_zone_dns_name" {
  description = "DNS name of the private zone"
  value       = google_dns_managed_zone.private_zone.dns_name
}

output "private_zone_id" {
  description = "ID of the private DNS zone"
  value       = google_dns_managed_zone.private_zone.id
}

output "public_zone_name" {
  description = "Name of the public DNS zone"
  value       = google_dns_managed_zone.public_zone.name
}

output "public_zone_dns_name" {
  description = "DNS name of the public zone"
  value       = google_dns_managed_zone.public_zone.dns_name
}

output "public_zone_id" {
  description = "ID of the public DNS zone"
  value       = google_dns_managed_zone.public_zone.id
}

output "public_zone_name_servers" {
  description = "Name servers for the public DNS zone"
  value       = google_dns_managed_zone.public_zone.name_servers
}

output "dns_policy_name" {
  description = "Name of the DNS policy"
  value       = google_dns_policy.private_dns_policy.name
}