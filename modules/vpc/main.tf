# Shared VPC Module

# Create the VPC network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
  project                 = var.project_id
  
  description = "Shared VPC network for DNS lab"
}

# Create subnets
resource "google_compute_subnetwork" "subnets" {
  count = length(var.subnets)
  
  name          = var.subnets[count.index].name
  ip_cidr_range = var.subnets[count.index].ip_cidr_range
  region        = var.subnets[count.index].region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
  description   = var.subnets[count.index].description
  
  # Enable private Google access
  private_ip_google_access = true
  
  # Secondary IP ranges for GKE (optional)
  secondary_ip_range {
    range_name    = "${var.subnets[count.index].name}-pods"
    ip_cidr_range = cidrsubnet(var.subnets[count.index].ip_cidr_range, 4, 1)
  }
  
  secondary_ip_range {
    range_name    = "${var.subnets[count.index].name}-services"
    ip_cidr_range = cidrsubnet(var.subnets[count.index].ip_cidr_range, 8, 1)
  }
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Create Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.subnets[0].region
  network = google_compute_network.vpc_network.id
  project = var.project_id
  
  bgp {
    asn = 64514
  }
}

# Create Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}