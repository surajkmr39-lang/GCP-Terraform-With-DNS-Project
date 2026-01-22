# Outputs for GCP Terraform DNS Lab

# VPC Outputs
output "network_name" {
  description = "Name of the VPC network"
  value       = module.shared_vpc.network_name
}

output "network_self_link" {
  description = "Self link of the VPC network"
  value       = module.shared_vpc.network_self_link
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = module.shared_vpc.subnet_names
}

output "subnet_self_links" {
  description = "Self links of the subnets"
  value       = module.shared_vpc.subnet_self_links
}

# DNS Outputs
output "private_zone_name" {
  description = "Name of the private DNS zone"
  value       = module.dns.private_zone_name
}

output "private_zone_dns_name" {
  description = "DNS name of the private zone"
  value       = module.dns.private_zone_dns_name
}

output "public_zone_name" {
  description = "Name of the public DNS zone"
  value       = module.dns.public_zone_name
}

output "public_zone_dns_name" {
  description = "DNS name of the public zone"
  value       = module.dns.public_zone_dns_name
}

output "public_zone_name_servers" {
  description = "Name servers for the public DNS zone"
  value       = module.dns.public_zone_name_servers
}

# Load Balancer Outputs
output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = module.load_balancer.load_balancer_ip
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = module.load_balancer.load_balancer_url
}

# WAF Outputs
output "waf_policy_name" {
  description = "Name of the Cloud Armor security policy"
  value       = module.waf.security_policy_name
}

# IAM Outputs
output "service_accounts" {
  description = "Created service accounts"
  value       = module.iam.service_accounts
  sensitive   = true
}

# Instance Outputs
output "web_instances" {
  description = "Web tier instances"
  value       = module.instances.web_instances
}

output "app_instances" {
  description = "App tier instances"
  value       = module.instances.app_instances
}

output "db_instances" {
  description = "Database tier instances"
  value       = module.instances.db_instances
}

output "bastion_instance" {
  description = "Bastion host details"
  value       = module.instances.bastion_instance
}

output "instance_summary" {
  description = "Summary of all created instances"
  value       = module.instances.instance_summary
}