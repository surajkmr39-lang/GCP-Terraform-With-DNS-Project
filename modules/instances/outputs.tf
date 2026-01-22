# Instances Module Outputs

# Web tier outputs
output "web_instances" {
  description = "Web tier instance details"
  value = {
    for idx, instance in google_compute_instance.web_instances : idx => {
      name        = instance.name
      zone        = instance.zone
      internal_ip = instance.network_interface[0].network_ip
      external_ip = length(instance.network_interface[0].access_config) > 0 ? instance.network_interface[0].access_config[0].nat_ip : null
      self_link   = instance.self_link
    }
  }
}

output "web_instance_names" {
  description = "Names of web tier instances"
  value       = google_compute_instance.web_instances[*].name
}

output "web_instance_ips" {
  description = "Internal IP addresses of web tier instances"
  value       = google_compute_instance.web_instances[*].network_interface[0].network_ip
}

# App tier outputs
output "app_instances" {
  description = "App tier instance details"
  value = {
    for idx, instance in google_compute_instance.app_instances : idx => {
      name        = instance.name
      zone        = instance.zone
      internal_ip = instance.network_interface[0].network_ip
      self_link   = instance.self_link
    }
  }
}

output "app_instance_names" {
  description = "Names of app tier instances"
  value       = google_compute_instance.app_instances[*].name
}

output "app_instance_ips" {
  description = "Internal IP addresses of app tier instances"
  value       = google_compute_instance.app_instances[*].network_interface[0].network_ip
}

# Database tier outputs
output "db_instances" {
  description = "Database tier instance details"
  value = {
    for idx, instance in google_compute_instance.db_instances : idx => {
      name        = instance.name
      zone        = instance.zone
      internal_ip = instance.network_interface[0].network_ip
      self_link   = instance.self_link
    }
  }
}

output "db_instance_names" {
  description = "Names of database tier instances"
  value       = google_compute_instance.db_instances[*].name
}

output "db_instance_ips" {
  description = "Internal IP addresses of database tier instances"
  value       = google_compute_instance.db_instances[*].network_interface[0].network_ip
}

# Bastion host outputs
output "bastion_instance" {
  description = "Bastion host details"
  value = var.create_bastion ? {
    name        = google_compute_instance.bastion[0].name
    zone        = google_compute_instance.bastion[0].zone
    internal_ip = google_compute_instance.bastion[0].network_interface[0].network_ip
    external_ip = google_compute_instance.bastion[0].network_interface[0].access_config[0].nat_ip
    self_link   = google_compute_instance.bastion[0].self_link
  } : null
}

# Instance groups
output "web_instance_groups" {
  description = "Web tier instance groups"
  value = {
    for idx, ig in google_compute_instance_group.web_instance_group : var.zones[idx] => ig.self_link
  }
}

# Health check
output "health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.instance_health_check.name
}

output "health_check_self_link" {
  description = "Self link of the health check"
  value       = google_compute_health_check.instance_health_check.self_link
}

# DNS records
output "dns_records" {
  description = "Created DNS records"
  value = {
    web_records = {
      for idx, record in google_dns_record_set.web_dns_records : idx => {
        name = record.name
        ip   = record.rrdatas[0]
      }
    }
    app_records = {
      for idx, record in google_dns_record_set.app_dns_records : idx => {
        name = record.name
        ip   = record.rrdatas[0]
      }
    }
    db_records = {
      for idx, record in google_dns_record_set.db_dns_records : idx => {
        name = record.name
        ip   = record.rrdatas[0]
      }
    }
  }
}

# Summary output
output "instance_summary" {
  description = "Summary of all created instances"
  value = {
    web_tier = {
      count     = var.web_instance_count
      instances = google_compute_instance.web_instances[*].name
    }
    app_tier = {
      count     = var.app_instance_count
      instances = google_compute_instance.app_instances[*].name
    }
    db_tier = {
      count     = var.db_instance_count
      instances = google_compute_instance.db_instances[*].name
    }
    bastion = {
      created = var.create_bastion
      name    = var.create_bastion ? google_compute_instance.bastion[0].name : null
    }
  }
}