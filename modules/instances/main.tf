# Compute Instances Module

# Web tier instances
resource "google_compute_instance" "web_instances" {
  count        = var.web_instance_count
  name         = "${var.instance_name_prefix}-web-${count.index + 1}"
  machine_type = var.web_machine_type
  zone         = var.zones[count.index % length(var.zones)]
  project      = var.project_id

  tags = ["web-server", "ssh-allowed", "lb-health-check", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.web_subnet_name
    
    # No external IP - instances will use NAT for internet access
    # Uncomment below for external IP if needed
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  service_account {
    email  = var.compute_service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = templatefile("${path.module}/scripts/web-startup.sh", {
      instance_name = "${var.instance_name_prefix}-web-${count.index + 1}"
      INSTANCE_NAME = "${var.instance_name_prefix}-web-${count.index + 1}"
      DNS_ZONE      = var.private_dns_zone
      PROJECT_ID    = var.project_id
    })
    ssh-keys = var.ssh_public_key != "" ? "ubuntu:${var.ssh_public_key}" : ""
  }

  metadata_startup_script = templatefile("${path.module}/scripts/web-startup.sh", {
    instance_name = "${var.instance_name_prefix}-web-${count.index + 1}"
    INSTANCE_NAME = "${var.instance_name_prefix}-web-${count.index + 1}"
    DNS_ZONE      = var.private_dns_zone
    PROJECT_ID    = var.project_id
  })

  labels = merge(var.labels, {
    tier = "web"
    role = "frontend"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application tier instances
resource "google_compute_instance" "app_instances" {
  count        = var.app_instance_count
  name         = "${var.instance_name_prefix}-app-${count.index + 1}"
  machine_type = var.app_machine_type
  zone         = var.zones[count.index % length(var.zones)]
  project      = var.project_id

  tags = ["app-server", "ssh-allowed", "internal-access"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.app_subnet_name
    
    # No external IP for security
  }

  service_account {
    email  = var.compute_service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = templatefile("${path.module}/scripts/app-startup.sh", {
      instance_name = "${var.instance_name_prefix}-app-${count.index + 1}"
      INSTANCE_NAME = "${var.instance_name_prefix}-app-${count.index + 1}"
      DNS_ZONE      = var.private_dns_zone
      PROJECT_ID    = var.project_id
      PORT          = "3000"
    })
    ssh-keys = var.ssh_public_key != "" ? "ubuntu:${var.ssh_public_key}" : ""
  }

  labels = merge(var.labels, {
    tier = "app"
    role = "backend"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database tier instances
resource "google_compute_instance" "db_instances" {
  count        = var.db_instance_count
  name         = "${var.instance_name_prefix}-db-${count.index + 1}"
  machine_type = var.db_machine_type
  zone         = var.zones[count.index % length(var.zones)]
  project      = var.project_id

  tags = ["db-server", "ssh-allowed", "internal-access"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.db_boot_disk_size
      type  = var.boot_disk_type
    }
  }

  # Additional persistent disk for database storage
  attached_disk {
    source      = google_compute_disk.db_data_disk[count.index].id
    device_name = "database-data"
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.db_subnet_name
    
    # No external IP for security
  }

  service_account {
    email  = var.compute_service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = templatefile("${path.module}/scripts/db-startup.sh", {
      instance_name = "${var.instance_name_prefix}-db-${count.index + 1}"
      INSTANCE_NAME = "${var.instance_name_prefix}-db-${count.index + 1}"
      DNS_ZONE      = var.private_dns_zone
      PROJECT_ID    = var.project_id
      DB_NAME       = "dns_lab_db"
      DB_USER       = "app_user"
      DB_PASSWORD   = "secure_password_123"
    })
    ssh-keys = var.ssh_public_key != "" ? "ubuntu:${var.ssh_public_key}" : ""
  }

  labels = merge(var.labels, {
    tier = "database"
    role = "storage"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Persistent disks for database instances
resource "google_compute_disk" "db_data_disk" {
  count = var.db_instance_count
  name  = "${var.instance_name_prefix}-db-data-${count.index + 1}"
  type  = "pd-ssd"
  zone  = var.zones[count.index % length(var.zones)]
  size  = var.db_data_disk_size
  project = var.project_id

  labels = merge(var.labels, {
    tier = "database"
    type = "data-disk"
  })
}

# Bastion host for secure access
resource "google_compute_instance" "bastion" {
  count        = var.create_bastion ? 1 : 0
  name         = "${var.instance_name_prefix}-bastion"
  machine_type = "e2-micro"
  zone         = var.zones[0]
  project      = var.project_id

  tags = ["bastion", "ssh-allowed"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.web_subnet_name
    
    # Bastion needs external IP for SSH access
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    email  = var.compute_service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = file("${path.module}/scripts/bastion-startup.sh")
    ssh-keys = var.ssh_public_key != "" ? "ubuntu:${var.ssh_public_key}" : ""
  }

  labels = merge(var.labels, {
    tier = "management"
    role = "bastion"
  })
}

# Create DNS records for instances in private zone
resource "google_dns_record_set" "web_dns_records" {
  count = var.web_instance_count
  
  name         = "web-${count.index + 1}.${var.private_dns_zone}"
  managed_zone = var.private_dns_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [google_compute_instance.web_instances[count.index].network_interface[0].network_ip]
}

resource "google_dns_record_set" "app_dns_records" {
  count = var.app_instance_count
  
  name         = "app-${count.index + 1}.${var.private_dns_zone}"
  managed_zone = var.private_dns_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [google_compute_instance.app_instances[count.index].network_interface[0].network_ip]
}

resource "google_dns_record_set" "db_dns_records" {
  count = var.db_instance_count
  
  name         = "db-${count.index + 1}.${var.private_dns_zone}"
  managed_zone = var.private_dns_zone_name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [google_compute_instance.db_instances[count.index].network_interface[0].network_ip]
}

# Load balancer instance group (unmanaged)
resource "google_compute_instance_group" "web_instance_group" {
  count = length(var.zones)
  
  name        = "${var.instance_name_prefix}-web-ig-${var.zones[count.index]}"
  description = "Web tier instance group for zone ${var.zones[count.index]}"
  zone        = var.zones[count.index]
  project     = var.project_id

  instances = [
    for instance in google_compute_instance.web_instances :
    instance.id if instance.zone == var.zones[count.index]
  ]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Health check for instances
resource "google_compute_health_check" "instance_health_check" {
  name               = "${var.instance_name_prefix}-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  project            = var.project_id

  http_health_check {
    port         = 80
    request_path = "/health"
  }

  log_config {
    enable = true
  }
}

# Firewall rule for health checks
resource "google_compute_firewall" "health_check_firewall" {
  name    = "${var.instance_name_prefix}-allow-health-check"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web-server", "lb-health-check"]
}