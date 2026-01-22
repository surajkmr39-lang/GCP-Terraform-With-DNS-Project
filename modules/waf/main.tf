# WAF Module - Cloud Armor Security Policies

# Cloud Armor security policy
resource "google_compute_security_policy" "waf_policy" {
  name    = "waf-security-policy"
  project = var.project_id
  
  description = "Cloud Armor WAF policy for DNS lab"
  
  # Default rule - allow all traffic
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }
  
  # Block specific countries (example: block traffic from certain regions)
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "origin.region_code == 'CN' || origin.region_code == 'RU'"
      }
    }
    description = "Block traffic from specific countries"
  }
  
  # Rate limiting rule
  rule {
    action   = "rate_based_ban"
    priority = "1001"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
      ban_duration_sec = 600
    }
    description = "Rate limit: 100 requests per minute per IP"
  }
  
  # Block SQL injection attempts
  rule {
    action   = "deny(403)"
    priority = "1002"
    match {
      expr {
        expression = "has(request.headers['user-agent']) && request.headers['user-agent'].contains('sqlmap')"
      }
    }
    description = "Block SQL injection tools"
  }
  
  # Block common attack patterns
  rule {
    action   = "deny(403)"
    priority = "1003"
    match {
      expr {
        expression = <<-EOT
          request.url_query.contains('union+select') ||
          request.url_query.contains('<script>') ||
          request.url_query.contains('javascript:') ||
          request.url_query.contains('../../../')
        EOT
      }
    }
    description = "Block common attack patterns in URL query"
  }
  
  # Allow specific trusted IP ranges
  rule {
    action   = "allow"
    priority = "500"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.trusted_ip_ranges
      }
    }
    description = "Allow trusted IP ranges"
  }
  
  # Block known bad IPs (only if blocked_ip_ranges is not empty)
  dynamic "rule" {
    for_each = length(var.blocked_ip_ranges) > 0 ? [1] : []
    content {
      action   = "deny(403)"
      priority = "600"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = var.blocked_ip_ranges
        }
      }
      description = "Block known malicious IP ranges"
    }
  }
  
  # Adaptive protection (requires Cloud Armor Plus)
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = true
      rule_visibility = "STANDARD"
    }
  }
}

# Attach the security policy to the backend service
# Note: This would typically be done in the load-balancer module
# but we're showing it here for completeness
# Attach WAF policy to backend service
resource "google_compute_backend_service" "web_backend_with_waf" {
  name        = "${var.backend_service_name}-with-waf"
  description = "Backend service with WAF policy attached"
  project     = var.project_id
  
  # Copy configuration from existing backend service
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  
  # Attach security policy
  security_policy = google_compute_security_policy.waf_policy.name
  
  # Health check
  health_checks = [google_compute_health_check.waf_health_check.id]
  
  # Backend configuration will be managed by load balancer module
  backend {
    group = "placeholder" # This will be updated by load balancer module
  }
}

# Health check for WAF-enabled backend
resource "google_compute_health_check" "waf_health_check" {
  name               = "waf-health-check"
  description        = "Health check for WAF-enabled backend"
  project            = var.project_id
  timeout_sec        = 5
  check_interval_sec = 10
  
  http_health_check {
    port         = 80
    request_path = "/health"
  }
}

# Create a custom WAF rule for API endpoints
resource "google_compute_security_policy" "api_waf_policy" {
  name    = "api-waf-security-policy"
  project = var.project_id
  
  description = "Specialized WAF policy for API endpoints"
  
  # Default rule
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule for API"
  }
  
  # Strict rate limiting for API
  rule {
    action   = "rate_based_ban"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 50
        interval_sec = 60
      }
      ban_duration_sec = 300
    }
    description = "API rate limit: 50 requests per minute per IP"
  }
  
  # Block requests without proper API headers
  rule {
    action   = "deny(400)"
    priority = "1001"
    match {
      expr {
        expression = "!has(request.headers['content-type']) && request.method == 'POST'"
      }
    }
    description = "Block POST requests without Content-Type header"
  }
}