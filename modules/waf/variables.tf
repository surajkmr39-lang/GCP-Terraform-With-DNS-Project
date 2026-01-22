# WAF Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "backend_service_name" {
  description = "Name of the backend service to attach WAF policy"
  type        = string
  default     = "web-backend"
}

variable "trusted_ip_ranges" {
  description = "List of trusted IP ranges to always allow"
  type        = list(string)
  default = [
    "35.235.240.0/20"  # Google Cloud Shell
  ]
}

variable "blocked_ip_ranges" {
  description = "List of IP ranges to block"
  type        = list(string)
  default     = []
}