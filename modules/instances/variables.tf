# Instances Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "web_subnet_name" {
  description = "Name of the web subnet"
  type        = string
}

variable "app_subnet_name" {
  description = "Name of the app subnet"
  type        = string
}

variable "db_subnet_name" {
  description = "Name of the database subnet"
  type        = string
}

variable "zones" {
  description = "List of zones for instance deployment"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "instance_name_prefix" {
  description = "Prefix for instance names"
  type        = string
  default     = "dns-lab"
}

# Web tier configuration
variable "web_instance_count" {
  description = "Number of web tier instances"
  type        = number
  default     = 2
}

variable "web_machine_type" {
  description = "Machine type for web instances"
  type        = string
  default     = "e2-medium"
}

# App tier configuration
variable "app_instance_count" {
  description = "Number of app tier instances"
  type        = number
  default     = 2
}

variable "app_machine_type" {
  description = "Machine type for app instances"
  type        = string
  default     = "e2-medium"
}

# Database tier configuration
variable "db_instance_count" {
  description = "Number of database tier instances"
  type        = number
  default     = 1
}

variable "db_machine_type" {
  description = "Machine type for database instances"
  type        = string
  default     = "e2-standard-2"
}

# Disk configuration
variable "boot_disk_image" {
  description = "Boot disk image for instances"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "db_boot_disk_size" {
  description = "Database boot disk size in GB"
  type        = number
  default     = 30
}

variable "db_data_disk_size" {
  description = "Database data disk size in GB"
  type        = number
  default     = 100
}

# Service account
variable "compute_service_account_email" {
  description = "Service account email for compute instances"
  type        = string
}

# DNS configuration
variable "private_dns_zone" {
  description = "Private DNS zone name"
  type        = string
}

variable "private_dns_zone_name" {
  description = "Private DNS zone resource name"
  type        = string
}

# SSH configuration
variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

# Bastion host
variable "create_bastion" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = true
}

# Labels
variable "labels" {
  description = "Labels to apply to instances"
  type        = map(string)
  default     = {}
}