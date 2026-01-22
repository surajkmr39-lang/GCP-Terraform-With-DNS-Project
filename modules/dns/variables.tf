# DNS Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "private_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
}

variable "private_dns_name" {
  description = "DNS name for the private zone"
  type        = string
}

variable "public_zone_name" {
  description = "Name of the public DNS zone"
  type        = string
}

variable "public_dns_name" {
  description = "DNS name for the public zone"
  type        = string
}