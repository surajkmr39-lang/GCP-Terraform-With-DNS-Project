# Firewall Module - Network Security Rules

# Allow HTTP traffic from internet
resource "google_compute_firewall" "allow_http" {
  name    = "${var.network_name}-allow-http"
  network = var.network_name
  project = var.project_id
  
  description = "Allow HTTP traffic from internet"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow HTTPS traffic from internet
resource "google_compute_firewall" "allow_https" {
  name    = "${var.network_name}-allow-https"
  network = var.network_name
  project = var.project_id
  
  description = "Allow HTTPS traffic from internet"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH from specific IP ranges
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = var.network_name
  project = var.project_id
  
  description = "Allow SSH from specific IP ranges"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh-allowed"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow internal communication between subnets
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = var.network_name
  project = var.project_id
  
  description = "Allow internal communication between subnets"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = var.internal_ranges
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow health check traffic from Google Load Balancer
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.network_name}-allow-health-check"
  network = var.network_name
  project = var.project_id
  
  description = "Allow health check traffic from Google Load Balancer"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  
  target_tags = ["lb-health-check"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Deny all other traffic (explicit deny rule)
resource "google_compute_firewall" "deny_all" {
  name    = "${var.network_name}-deny-all"
  network = var.network_name
  project = var.project_id
  
  description = "Deny all other traffic"
  direction   = "INGRESS"
  priority    = 65534
  
  deny {
    protocol = "all"
  }
  
  source_ranges = ["0.0.0.0/0"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow DNS traffic (UDP 53)
resource "google_compute_firewall" "allow_dns" {
  name    = "${var.network_name}-allow-dns"
  network = var.network_name
  project = var.project_id
  
  description = "Allow DNS traffic"
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }
  
  source_ranges = var.internal_ranges
  target_tags   = ["dns-server"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Egress rule for internet access
resource "google_compute_firewall" "allow_egress" {
  name    = "${var.network_name}-allow-egress"
  network = var.network_name
  project = var.project_id
  
  description = "Allow egress traffic to internet"
  direction   = "EGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  allow {
    protocol = "icmp"
  }
  
  destination_ranges = ["0.0.0.0/0"]
  
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}