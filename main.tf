# GCP Terraform DNS Lab - Main Configuration
# This lab demonstrates DNS, Shared VPC, IAM, GLB, WAF, and Firewall

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "dns.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudasset.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Shared VPC Host Project
module "shared_vpc" {
  source = "./modules/vpc"

  project_id   = var.project_id
  network_name = var.network_name
  subnets      = var.subnets

  depends_on = [google_project_service.required_apis]
}

# DNS Configuration
module "dns" {
  source = "./modules/dns"

  project_id        = var.project_id
  network_self_link = module.shared_vpc.network_self_link
  private_zone_name = var.private_zone_name
  private_dns_name  = var.private_dns_name
  public_zone_name  = var.public_zone_name
  public_dns_name   = var.public_dns_name

  depends_on = [module.shared_vpc]
}

# IAM Configuration
module "iam" {
  source = "./modules/iam"

  project_id = var.project_id

  depends_on = [google_project_service.required_apis]
}

# Firewall Rules
module "firewall" {
  source = "./modules/firewall"

  project_id   = var.project_id
  network_name = module.shared_vpc.network_name

  depends_on = [module.shared_vpc]
}

# Global Load Balancer with WAF
module "load_balancer" {
  source = "./modules/load-balancer"

  project_id      = var.project_id
  network_name    = module.shared_vpc.network_name
  subnet_name     = module.shared_vpc.subnet_names[0]
  instance_groups = module.instances.web_instance_groups

  depends_on = [module.shared_vpc, module.firewall, module.instances]
}

# Cloud Armor WAF Policy
module "waf" {
  source = "./modules/waf"

  project_id = var.project_id

  depends_on = [google_project_service.required_apis]
}

# Compute Instances
module "instances" {
  source = "./modules/instances"

  project_id      = var.project_id
  network_name    = module.shared_vpc.network_name
  web_subnet_name = module.shared_vpc.subnet_names[0]
  app_subnet_name = module.shared_vpc.subnet_names[1]
  db_subnet_name  = length(module.shared_vpc.subnet_names) > 2 ? module.shared_vpc.subnet_names[2] : module.shared_vpc.subnet_names[1]

  # Instance configuration
  web_instance_count = var.web_instance_count
  app_instance_count = var.app_instance_count
  db_instance_count  = length(module.shared_vpc.subnet_names) > 2 ? var.db_instance_count : 0

  # Service account
  compute_service_account_email = module.iam.service_accounts.compute_sa.email

  # DNS configuration
  private_dns_zone      = var.private_dns_name
  private_dns_zone_name = module.dns.private_zone_name

  # SSH configuration
  ssh_public_key = var.ssh_public_key
  create_bastion = var.create_bastion

  # Labels
  labels = var.labels

  depends_on = [module.shared_vpc, module.dns, module.iam, module.firewall]
}