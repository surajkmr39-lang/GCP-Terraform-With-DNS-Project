# IAM Module Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "lab_users" {
  description = "List of user emails for lab access"
  type        = list(string)
  default     = []
}