# Variables for GCP Terraform DNS Lab

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "shared-vpc-network"
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = string
  }))
  default = [
    {
      name          = "subnet-web"
      ip_cidr_range = "10.0.1.0/24"
      region        = "us-central1"
      description   = "Web tier subnet"
    },
    {
      name          = "subnet-app"
      ip_cidr_range = "10.0.2.0/24"
      region        = "us-central1"
      description   = "Application tier subnet"
    },
    {
      name          = "subnet-db"
      ip_cidr_range = "10.0.3.0/24"
      region        = "us-central1"
      description   = "Database tier subnet"
    }
  ]
}

variable "private_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
  default     = "private-zone"
}

variable "private_dns_name" {
  description = "DNS name for the private zone"
  type        = string
  default     = "internal.example.com."
}

variable "public_zone_name" {
  description = "Name of the public DNS zone"
  type        = string
  default     = "public-zone"
}

variable "public_dns_name" {
  description = "DNS name for the public zone"
  type        = string
  default     = "example.com."
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "lab"
    project     = "dns-lab"
    managed-by  = "terraform"
  }
}

# Instance Configuration
variable "web_instance_count" {
  description = "Number of web tier instances"
  type        = number
  default     = 2
}

variable "app_instance_count" {
  description = "Number of app tier instances"
  type        = number
  default     = 2
}

variable "db_instance_count" {
  description = "Number of database tier instances"
  type        = number
  default     = 1
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

variable "create_bastion" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = true
}