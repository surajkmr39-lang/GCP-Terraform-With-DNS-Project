# Load Balancer Module - Global HTTP(S) Load Balancer

# Create instance template for backend instances
resource "google_compute_instance_template" "web_template" {
  name_prefix  = "web-template-"
  machine_type = "e2-micro"
  project      = var.project_id
  
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }
  
  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    
    # No external IP - instances will use NAT for internet access
  }
  
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    # Create a simple HTML page with instance info
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>GCP DNS Lab - Web Server</title>
    </head>
    <body>
        <h1>Welcome to GCP DNS Lab</h1>
        <p>Server: $(hostname)</p>
        <p>Zone: $(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)</p>
        <p>Instance ID: $(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/id" -H "Metadata-Flavor: Google")</p>
    </body>
    </html>
HTML
    
    systemctl enable nginx
    systemctl start nginx
  EOF
  
  tags = ["web-server", "lb-health-check"]
  
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create managed instance group (only if no external instance groups provided)
resource "google_compute_region_instance_group_manager" "web_igm" {
  count = length(var.instance_groups) == 0 ? 1 : 0
  
  name               = "web-igm"
  base_instance_name = "web-instance"
  region             = var.region
  project            = var.project_id
  
  version {
    instance_template = google_compute_instance_template.web_template.id
  }
  
  target_size = 2
  
  named_port {
    name = "http"
    port = 80
  }
  
  auto_healing_policies {
    health_check      = google_compute_health_check.web_health_check.id
    initial_delay_sec = 300
  }
}

# Health check for backend instances
resource "google_compute_health_check" "web_health_check" {
  name    = "web-health-check"
  project = var.project_id
  
  timeout_sec        = 5
  check_interval_sec = 10
  
  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# Backend service
resource "google_compute_backend_service" "web_backend" {
  name        = "web-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  project     = var.project_id
  
  # Use instance groups from instances module if provided
  dynamic "backend" {
    for_each = var.instance_groups
    content {
      group           = backend.value
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
    }
  }
  
  # Fallback to managed instance group if no instance groups provided
  dynamic "backend" {
    for_each = length(var.instance_groups) == 0 ? [1] : []
    content {
      group           = google_compute_region_instance_group_manager.web_igm[0].instance_group
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
    }
  }
  
  health_checks = [google_compute_health_check.web_health_check.id]
  
  # Enable Cloud CDN
  enable_cdn = true
  
  cdn_policy {
    cache_mode                   = "CACHE_ALL_STATIC"
    default_ttl                  = 3600
    max_ttl                      = 86400
    negative_caching             = true
    serve_while_stale            = 86400
    signed_url_cache_max_age_sec = 7200
  }
  
  # Connection draining
  connection_draining_timeout_sec = 300
  
  # Security policy (WAF) will be attached via the WAF module
}

# URL map
resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
  project         = var.project_id
  
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.web_backend.id
    
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.web_backend.id
    }
  }
}

# HTTP(S) proxy
resource "google_compute_target_http_proxy" "web_http_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web_url_map.id
  project = var.project_id
}

# Global forwarding rule (HTTP)
resource "google_compute_global_forwarding_rule" "web_http_forwarding_rule" {
  name       = "web-http-forwarding-rule"
  target     = google_compute_target_http_proxy.web_http_proxy.id
  port_range = "80"
  project    = var.project_id
}

# SSL certificate (managed)
resource "google_compute_managed_ssl_certificate" "web_ssl_cert" {
  name    = "web-ssl-cert"
  project = var.project_id
  
  managed {
    domains = var.ssl_domains
  }
}

# HTTPS proxy
resource "google_compute_target_https_proxy" "web_https_proxy" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.web_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.web_ssl_cert.id]
  project          = var.project_id
}

# Global forwarding rule (HTTPS)
resource "google_compute_global_forwarding_rule" "web_https_forwarding_rule" {
  name       = "web-https-forwarding-rule"
  target     = google_compute_target_https_proxy.web_https_proxy.id
  port_range = "443"
  project    = var.project_id
}