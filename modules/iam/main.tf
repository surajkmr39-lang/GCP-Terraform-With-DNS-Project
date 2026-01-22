# IAM Module - Service Accounts and Roles

# Service Account for Compute Engine instances
resource "google_service_account" "compute_sa" {
  account_id   = "compute-service-account"
  display_name = "Compute Engine Service Account"
  description  = "Service account for Compute Engine instances in DNS lab"
  project      = var.project_id
}

# Service Account for DNS management
resource "google_service_account" "dns_sa" {
  account_id   = "dns-service-account"
  display_name = "DNS Management Service Account"
  description  = "Service account for DNS management operations"
  project      = var.project_id
}

# Service Account for Load Balancer
resource "google_service_account" "lb_sa" {
  account_id   = "lb-service-account"
  display_name = "Load Balancer Service Account"
  description  = "Service account for Load Balancer operations"
  project      = var.project_id
}

# Custom IAM Role for DNS operations
resource "google_project_iam_custom_role" "dns_manager" {
  role_id     = "dnsManager"
  title       = "DNS Manager"
  description = "Custom role for DNS management operations"
  project     = var.project_id
  
  permissions = [
    "dns.managedZones.create",
    "dns.managedZones.delete",
    "dns.managedZones.get",
    "dns.managedZones.list",
    "dns.managedZones.update",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.get",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
    "dns.policies.create",
    "dns.policies.delete",
    "dns.policies.get",
    "dns.policies.list",
    "dns.policies.update"
  ]
}

# IAM bindings for Compute Service Account
resource "google_project_iam_member" "compute_sa_bindings" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/compute.networkAdmin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.compute_sa.email}"
}

# IAM bindings for DNS Service Account
resource "google_project_iam_member" "dns_sa_bindings" {
  for_each = toset([
    "projects/${var.project_id}/roles/dnsManager",
    "roles/dns.admin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dns_sa.email}"
}

# IAM bindings for Load Balancer Service Account
resource "google_project_iam_member" "lb_sa_bindings" {
  for_each = toset([
    "roles/compute.loadBalancerAdmin",
    "roles/compute.securityAdmin",
    "roles/logging.logWriter"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.lb_sa.email}"
}

# Create a custom group for lab users
resource "google_project_iam_member" "lab_users" {
  count = length(var.lab_users)
  
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:${var.lab_users[count.index]}"
}

# Grant specific permissions to lab users
resource "google_project_iam_member" "lab_users_compute" {
  count = length(var.lab_users)
  
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "user:${var.lab_users[count.index]}"
}

resource "google_project_iam_member" "lab_users_dns" {
  count = length(var.lab_users)
  
  project = var.project_id
  role    = "roles/dns.reader"
  member  = "user:${var.lab_users[count.index]}"
}

# Service Account Keys (for demonstration - not recommended for production)
resource "google_service_account_key" "compute_sa_key" {
  service_account_id = google_service_account.compute_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_service_account_key" "dns_sa_key" {
  service_account_id = google_service_account.dns_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}