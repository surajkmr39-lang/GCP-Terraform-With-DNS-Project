# VPC Module Outputs

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = google_compute_subnetwork.subnets[*].name
}

output "subnet_self_links" {
  description = "Self links of the subnets"
  value       = google_compute_subnetwork.subnets[*].self_link
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = google_compute_subnetwork.subnets[*].id
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.nat.name
}