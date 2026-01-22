# Load Balancer Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet for backend instances"
  type        = string
}

variable "region" {
  description = "Region for the managed instance group"
  type        = string
  default     = "us-central1"
}

variable "service_account_email" {
  description = "Service account email for backend instances"
  type        = string
  default     = null
}

variable "ssl_domains" {
  description = "Domains for SSL certificate"
  type        = list(string)
  default     = ["example.com", "www.example.com"]
}

variable "instance_groups" {
  description = "Instance groups for the load balancer backend"
  type        = map(string)
  default     = {}
}