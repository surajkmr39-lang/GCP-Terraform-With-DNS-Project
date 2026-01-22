# Firewall Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  default = [
    "35.235.240.0/20"  # Google Cloud Shell
  ]
}

variable "internal_ranges" {
  description = "Internal IP ranges for subnet communication"
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}