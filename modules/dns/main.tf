# DNS Module - Private and Public DNS Zones

# Private DNS Zone
resource "google_dns_managed_zone" "private_zone" {
  name        = var.private_zone_name
  dns_name    = var.private_dns_name
  description = "Private DNS zone for internal resources"
  project     = var.project_id
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = var.network_self_link
    }
  }
  
  labels = {
    environment = "lab"
    type        = "private"
  }
}

# Private DNS Records
resource "google_dns_record_set" "private_a_record" {
  name         = "web.${google_dns_managed_zone.private_zone.dns_name}"
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "A"
  ttl          = 300
  project      = var.project_id
  
  rrdatas = ["10.0.1.10"]
}

resource "google_dns_record_set" "private_cname_record" {
  name         = "app.${google_dns_managed_zone.private_zone.dns_name}"
  managed_zone = google_dns_managed_zone.private_zone.name
  type         = "CNAME"
  ttl          = 300
  project      = var.project_id
  
  rrdatas = ["web.${google_dns_managed_zone.private_zone.dns_name}"]
}

# Public DNS Zone
resource "google_dns_managed_zone" "public_zone" {
  name        = var.public_zone_name
  dns_name    = var.public_dns_name
  description = "Public DNS zone for external resources"
  project     = var.project_id
  
  visibility = "public"
  
  labels = {
    environment = "lab"
    type        = "public"
  }
}

# Public DNS Records
resource "google_dns_record_set" "public_a_record" {
  name         = "www.${google_dns_managed_zone.public_zone.dns_name}"
  managed_zone = google_dns_managed_zone.public_zone.name
  type         = "A"
  ttl          = 300
  project      = var.project_id
  
  rrdatas = ["34.102.136.180"] # Example public IP
}

resource "google_dns_record_set" "public_mx_record" {
  name         = google_dns_managed_zone.public_zone.dns_name
  managed_zone = google_dns_managed_zone.public_zone.name
  type         = "MX"
  ttl          = 3600
  project      = var.project_id
  
  rrdatas = [
    "10 mail.${google_dns_managed_zone.public_zone.dns_name}",
    "20 mail2.${google_dns_managed_zone.public_zone.dns_name}"
  ]
}

resource "google_dns_record_set" "public_txt_record" {
  name         = google_dns_managed_zone.public_zone.dns_name
  managed_zone = google_dns_managed_zone.public_zone.name
  type         = "TXT"
  ttl          = 300
  project      = var.project_id
  
  rrdatas = [
    "\"v=spf1 include:_spf.google.com ~all\"",
    "\"google-site-verification=example123456789\""
  ]
}

# DNS Policy for private zone
resource "google_dns_policy" "private_dns_policy" {
  name                      = "${var.private_zone_name}-policy"
  enable_inbound_forwarding = true
  enable_logging            = true
  project                   = var.project_id
  
  networks {
    network_url = var.network_self_link
  }
  
  alternative_name_server_config {
    target_name_servers {
      ipv4_address    = "8.8.8.8"
      forwarding_path = "default"
    }
    target_name_servers {
      ipv4_address    = "8.8.4.4"
      forwarding_path = "default"
    }
  }
}