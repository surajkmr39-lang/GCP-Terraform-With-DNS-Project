# 🔥🛡️🌐 Firewall, WAF & Global Load Balancer Complete Guide

## 📋 Overview: Three-Layer Architecture

Your project implements **three integrated components** working together:

1. **🌐 Global Load Balancer (GLB)** - Traffic distribution and SSL termination
2. **�️ VPC Firewall Rules** - Network-level security (Layer 3/4)
3. **🛡️ Cloud Armor WAF** - Application-level security (Layer 7)

---

## 🌐 Global Load Balancer (GLB) - Traffic Distribution

### **What is Google Cloud Load Balancer?**
```yaml
Purpose: Distributes incoming traffic across multiple backend instances
Layer: OSI Layer 7 (Application) for HTTP(S), Layer 4 for TCP/UDP
Scope: Global (multi-region) or Regional
Technology: Anycast IP, Edge locations worldwide
```

### **🏗️ GLB Components in Your Project**

#### **1. Global Forwarding Rules**
```hcl
# HTTP Forwarding Rule
resource "google_compute_global_forwarding_rule" "web_http_forwarding_rule" {
  name       = "web-http-forwarding-rule"
  target     = google_compute_target_http_proxy.web_http_proxy.id
  port_range = "80"
}

# HTTPS Forwarding Rule  
resource "google_compute_global_forwarding_rule" "web_https_forwarding_rule" {
  name       = "web-https-forwarding-rule"
  target     = google_compute_target_https_proxy.web_https_proxy.id
  port_range = "443"
}
```

**Real-world Example:**
```bash
# User requests from anywhere in the world
curl http://34.102.136.180/
# Traffic automatically routed to nearest Google edge location
# Then forwarded to your backend instances in us-central1

# Global IP address (Anycast)
# Same IP works from:
# - New York → Routes to us-east edge
# - London → Routes to europe-west edge  
# - Tokyo → Routes to asia-northeast edge
# All eventually reach your us-central1 backends
```

#### **2. Backend Services & Instance Groups**
```hcl
resource "google_compute_backend_service" "web_backend" {
  name        = "web-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  
  backend {
    group           = google_compute_region_instance_group_manager.web_igm.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  
  health_checks = [google_compute_health_check.web_health_check.id]
  enable_cdn    = true
}
```

**Real-world Example:**
```bash
# Your backend has 2 web servers:
# - web-instance-1 (10.0.1.10) - 60% CPU usage
# - web-instance-2 (10.0.1.11) - 40% CPU usage

# Load balancer distributes traffic based on utilization:
# Request 1 → web-instance-2 (lower CPU)
# Request 2 → web-instance-2 (still lower)
# Request 3 → web-instance-1 (now balanced)

# If web-instance-1 fails health check:
# All traffic → web-instance-2 (automatic failover)
```

#### **3. Health Checks**
```hcl
resource "google_compute_health_check" "web_health_check" {
  name               = "web-health-check"
  timeout_sec        = 5
  check_interval_sec = 10
  
  http_health_check {
    port         = 80
    request_path = "/"
  }
}
```

**Real-world Example:**
```bash
# Every 10 seconds, GLB sends to each instance:
GET / HTTP/1.1
Host: 10.0.1.10
User-Agent: GoogleHC/1.0

# Healthy response (HTTP 200):
HTTP/1.1 200 OK
Content-Type: text/html
# Instance stays in rotation

# Unhealthy response (HTTP 500 or timeout):
HTTP/1.1 500 Internal Server Error
# Instance removed from rotation after 2 consecutive failures
# Traffic stops going to this instance
```

#### **4. SSL/TLS Termination**
```hcl
resource "google_compute_managed_ssl_certificate" "web_ssl_cert" {
  name = "web-ssl-cert"
  
  managed {
    domains = ["learningmyway.space", "www.learningmyway.space"]
  }
}

resource "google_compute_target_https_proxy" "web_https_proxy" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.web_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.web_ssl_cert.id]
}
```

**Real-world Example:**
```bash
# User makes HTTPS request:
curl https://learningmyway.space/

# SSL termination at load balancer:
# 1. Client ↔ GLB: Encrypted HTTPS (SSL/TLS)
# 2. GLB ↔ Backend: Unencrypted HTTP (internal network)

# Benefits:
# - Reduces CPU load on backend servers
# - Centralized certificate management
# - Automatic certificate renewal
# - Better performance (SSL offloading)
```

#### **5. URL Mapping & Path-Based Routing**
```hcl
resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
  
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.web_backend.id
    
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.web_backend.id
    }
  }
}
```

**Real-world Example:**
```bash
# Different paths can route to different backends:

# Web requests → Web backend
curl https://learningmyway.space/
curl https://learningmyway.space/about
curl https://learningmyway.space/contact

# API requests → API backend (same in this lab, but could be different)
curl https://learningmyway.space/api/users
curl https://learningmyway.space/api/orders

# Future expansion example:
# /api/* → API backend service (Node.js/Python)
# /static/* → Storage bucket (static files)
# /* → Web backend service (Nginx/Apache)
```

#### **6. Cloud CDN Integration**
```hcl
cdn_policy {
  cache_mode                   = "CACHE_ALL_STATIC"
  default_ttl                  = 3600
  max_ttl                      = 86400
  negative_caching             = true
  serve_while_stale            = 86400
}
```

**Real-world Example:**
```bash
# First request from London:
curl https://learningmyway.space/images/logo.png
# Response: 200 OK (served from us-central1, cached at London edge)
# Response time: 200ms

# Second request from London (same user or different):
curl https://learningmyway.space/images/logo.png  
# Response: 200 OK (served from London edge cache)
# Response time: 20ms (10x faster!)

# Cache headers:
Cache-Control: public, max-age=3600
X-Cache: HIT
X-Cache-Hits: 1
```

---

## 🔥 VPC Firewall Rules (Network Security)

### **What is VPC Firewall?**
```yaml
Purpose: Controls network traffic at IP/Port level
Layer: OSI Layer 3 (Network) & Layer 4 (Transport)
Scope: Entire VPC network
Technology: Stateful firewall rules
```

### **🎯 Firewall Rules in Your Project**

#### **1. Allow HTTP Traffic (Port 80)**
```hcl
resource "google_compute_firewall" "allow_http" {
  name          = "shared-vpc-network-allow-http"
  direction     = "INGRESS"
  priority      = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = ["0.0.0.0/0"]  # From anywhere on internet
  target_tags   = ["web-server"] # Only to instances with this tag
}
```

**Real-world Example:**
```bash
# This allows:
curl http://your-load-balancer-ip/
# User → Internet → Load Balancer → Web Server (Port 80)

# This blocks:
curl http://your-web-server-internal-ip/
# Direct access to internal IP is blocked
```

#### **2. Allow HTTPS Traffic (Port 443)**
```hcl
resource "google_compute_firewall" "allow_https" {
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
```

**Real-world Example:**
```bash
# This allows:
curl https://your-load-balancer-ip/
# Secure HTTPS traffic to web servers

# Use case: E-commerce, banking, any secure web traffic
```

#### **3. Allow SSH Access (Port 22)**
```hcl
resource "google_compute_firewall" "allow_ssh" {
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]  # Google Cloud Shell only
  target_tags   = ["ssh-allowed"]
}
```

**Real-world Example:**
```bash
# This allows:
gcloud compute ssh bastion-host --zone=us-central1-a
# SSH from Cloud Shell to bastion host

# This blocks:
ssh user@bastion-external-ip  # From random internet IP
# Direct SSH from untrusted sources blocked
```

#### **4. Internal Communication**
```hcl
resource "google_compute_firewall" "allow_internal" {
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]  # All TCP ports
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]  # All UDP ports
  }
  allow {
    protocol = "icmp"      # Ping traffic
  }
  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
```

**Real-world Example:**
```bash
# From web server (10.0.1.10):
curl http://app-1.internal.learningmyway.space:3000/api/users
# Web → App server communication allowed

# From app server (10.0.2.10):
psql -h db-1.internal.learningmyway.space -U appuser -d dnslab
# App → Database communication allowed

# Ping between servers:
ping 10.0.2.10  # Works within VPC
```

#### **5. Load Balancer Health Checks**
```hcl
resource "google_compute_firewall" "allow_health_check" {
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  source_ranges = [
    "130.211.0.0/22",  # Google Load Balancer ranges
    "35.191.0.0/16"
  ]
  target_tags = ["lb-health-check"]
}
```

**Real-world Example:**
```bash
# Google Load Balancer automatically sends:
GET /health HTTP/1.1
Host: your-web-server
# Every 10 seconds to check server health

# Without this rule, health checks would fail
# Result: Servers marked unhealthy, traffic stops
```

#### **6. DNS Traffic (Port 53)**
```hcl
resource "google_compute_firewall" "allow_dns" {
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
}
```

**Real-world Example:**
```bash
# From any server:
nslookup app-1.internal.learningmyway.space
# DNS queries to resolve internal hostnames

# From web server:
dig db-1.internal.learningmyway.space
# Service discovery for database connection
```

#### **7. Explicit Deny All (Security)**
```hcl
resource "google_compute_firewall" "deny_all" {
  direction = "INGRESS"
  priority  = 65534  # Lowest priority (evaluated last)
  
  deny {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
}
```

**Real-world Example:**
```bash
# This blocks:
telnet your-server-ip 23    # Telnet blocked
ftp your-server-ip          # FTP blocked  
ssh user@server-ip -p 2222  # Non-standard SSH port blocked

# Security principle: "Default deny, explicit allow"
```

---

## 🛡️ Cloud Armor WAF (Application Security)

### **What is Cloud Armor WAF?**
```yaml
Purpose: Protects web applications from attacks
Layer: OSI Layer 7 (Application)
Scope: HTTP/HTTPS traffic only
Technology: Deep packet inspection, pattern matching
```

### **🎯 WAF Rules in Your Project**

#### **1. Rate Limiting Protection**
```hcl
rule {
  action   = "rate_based_ban"
  priority = "1001"
  
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
}
```

**Real-world Example:**
```bash
# Normal user (allowed):
for i in {1..50}; do curl http://your-site.com; done
# 50 requests in 60 seconds → Allowed

# Attacker/Bot (blocked):
for i in {1..150}; do curl http://your-site.com; done
# 150 requests in 60 seconds → HTTP 429 (Too Many Requests)
# IP banned for 10 minutes

# Use cases:
# - DDoS protection
# - API abuse prevention  
# - Brute force attack mitigation
```

#### **2. Geographic Blocking**
```hcl
rule {
  action   = "deny(403)"
  priority = "1000"
  match {
    expr {
      expression = "origin.region_code == 'CN' || origin.region_code == 'RU'"
    }
  }
}
```

**Real-world Example:**
```bash
# Request from China:
curl -H "CF-IPCountry: CN" http://your-site.com
# Response: HTTP 403 Forbidden

# Request from US:
curl -H "CF-IPCountry: US" http://your-site.com  
# Response: HTTP 200 OK

# Use cases:
# - Compliance requirements (GDPR, sanctions)
# - Reduce attack surface
# - Licensing restrictions
```

#### **3. SQL Injection Protection**
```hcl
rule {
  action   = "deny(403)"
  priority = "1002"
  match {
    expr {
      expression = "has(request.headers['user-agent']) && request.headers['user-agent'].contains('sqlmap')"
    }
  }
}
```

**Real-world Example:**
```bash
# Malicious request (blocked):
curl -H "User-Agent: sqlmap/1.4.7" http://your-site.com/login
# Response: HTTP 403 Forbidden

# Normal browser (allowed):
curl -H "User-Agent: Mozilla/5.0 (Chrome)" http://your-site.com/login
# Response: HTTP 200 OK

# Also blocks:
curl "http://your-site.com/search?q='; DROP TABLE users; --"
# SQL injection attempt blocked
```

#### **4. Cross-Site Scripting (XSS) Protection**
```hcl
rule {
  action   = "deny(403)"
  priority = "1003"
  match {
    expr {
      expression = <<-EOT
        request.url_query.contains('<script>') ||
        request.url_query.contains('javascript:') ||
        request.url_query.contains('../../../')
      EOT
    }
  }
}
```

**Real-world Example:**
```bash
# XSS attempt (blocked):
curl "http://your-site.com/search?q=<script>alert('XSS')</script>"
# Response: HTTP 403 Forbidden

# Path traversal attempt (blocked):
curl "http://your-site.com/file?path=../../../etc/passwd"
# Response: HTTP 403 Forbidden

# Normal search (allowed):
curl "http://your-site.com/search?q=terraform+tutorial"
# Response: HTTP 200 OK
```

#### **5. API-Specific Protection**
```hcl
# Separate policy for API endpoints
resource "google_compute_security_policy" "api_waf_policy" {
  rule {
    action   = "deny(400)"
    priority = "1001"
    match {
      expr {
        expression = "!has(request.headers['content-type']) && request.method == 'POST'"
      }
    }
  }
}
```

**Real-world Example:**
```bash
# Invalid API request (blocked):
curl -X POST http://your-api.com/users
# Missing Content-Type header → HTTP 400 Bad Request

# Valid API request (allowed):
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"John"}' http://your-api.com/users
# Response: HTTP 201 Created

# Stricter rate limiting for APIs:
# 50 requests/minute vs 100 for web pages
```

---

## 🔄 How GLB, Firewall & WAF Work Together

### **Complete Traffic Flow**

```
Internet User → Google Edge (GLB) → Cloud Armor (WAF) → VPC Firewall → Backend Instances
```

#### **Detailed Request Journey:**

**1. DNS Resolution:**
```bash
# User types: https://learningmyway.space
# DNS lookup returns: 34.102.136.180 (GLB Anycast IP)
dig learningmyway.space
# Answer: learningmyway.space. 300 IN A 34.102.136.180
```

**2. Global Load Balancer (Entry Point):**
```bash
# Request hits nearest Google edge location
# GLB determines:
# - SSL termination needed (HTTPS)
# - Route to backend service
# - Apply URL mapping rules
```

**3. Cloud Armor WAF (Security Check):**
```bash
# WAF evaluates request against rules:
# ✅ Rate limit: 45 requests this minute (under 100 limit)
# ✅ Geographic: Request from US (allowed)
# ✅ Content: No SQL injection patterns detected
# ✅ User-Agent: Normal browser (not attack tool)
# → Request ALLOWED, forward to backend
```

**4. VPC Firewall (Network Security):**
```bash
# Firewall checks:
# ✅ Source: Google Load Balancer IP range (130.211.0.0/22)
# ✅ Destination: Backend instance (10.0.1.10)
# ✅ Protocol: TCP
# ✅ Port: 80 (HTTP)
# ✅ Target tags: web-server (matches instance)
# → Traffic ALLOWED through firewall
```

**5. Backend Instance (Final Destination):**
```bash
# Request reaches web server:
GET / HTTP/1.1
Host: learningmyway.space
X-Forwarded-For: 203.0.113.1
X-Forwarded-Proto: https

# Server processes and responds:
HTTP/1.1 200 OK
Content-Type: text/html
# Response travels back through same path
```

---

## 🎯 GLB Use Cases & Benefits

### **1. High Availability & Disaster Recovery**

#### **Multi-Zone Deployment:**
```yaml
Current Setup:
  - Primary: us-central1-a (web-instance-1)
  - Secondary: us-central1-b (web-instance-2)
  
Failure Scenario:
  - Zone us-central1-a fails
  - GLB automatically routes all traffic to us-central1-b
  - Zero downtime for users
```

**Real-world Example:**
```bash
# Normal operation:
curl https://learningmyway.space/
# Response from: web-instance-1 (us-central1-a)

# Zone failure simulation:
gcloud compute instances stop web-instance-1 --zone=us-central1-a

# Automatic failover:
curl https://learningmyway.space/
# Response from: web-instance-2 (us-central1-b)
# User doesn't notice the failure!
```

#### **Multi-Region Expansion:**
```yaml
Future Expansion:
  Primary Region: us-central1 (2 instances)
  Secondary Region: europe-west1 (2 instances)
  
Traffic Distribution:
  - US users → us-central1 backends
  - European users → europe-west1 backends
  - Automatic failover between regions
```

### **2. Auto-Scaling & Performance**

#### **Instance Group Auto-Scaling:**
```hcl
# Future enhancement
resource "google_compute_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  target = google_compute_region_instance_group_manager.web_igm.id
  
  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 2
    cooldown_period = 60
    
    cpu_utilization {
      target = 0.7  # Scale up when CPU > 70%
    }
  }
}
```

**Real-world Example:**
```bash
# Normal traffic: 2 instances handle load
# CPU usage: 30% each

# Traffic spike (Black Friday, viral content):
# CPU usage jumps to 80%
# Auto-scaler triggers: Creates 2 more instances
# GLB automatically includes new instances
# CPU usage drops to 40% each (4 instances)

# Traffic returns to normal:
# Auto-scaler removes extra instances
# Back to 2 instances
```

### **3. Global Content Delivery**

#### **CDN Performance:**
```yaml
Without CDN:
  User in Sydney → us-central1 → 300ms latency
  
With CDN:
  User in Sydney → Sydney edge cache → 20ms latency
  Cache hit ratio: 85% for static content
```

**Real-world Example:**
```bash
# Static assets cached globally:
curl https://learningmyway.space/css/style.css
# First request: 300ms (origin)
# Subsequent requests: 20ms (edge cache)

# Dynamic content still goes to origin:
curl https://learningmyway.space/api/user/profile
# Always: 300ms (not cacheable)
```

### **4. SSL/TLS Management**

#### **Automatic Certificate Management:**
```yaml
Benefits:
  - Automatic provisioning
  - Automatic renewal (90 days before expiry)
  - Multiple domain support
  - Perfect Forward Secrecy
  - Modern TLS protocols (1.2, 1.3)
```

**Real-world Example:**
```bash
# Certificate automatically obtained:
curl -I https://learningmyway.space/
# HTTP/2 200
# server: gws
# x-ssl-cert: Google-managed certificate
# Certificate valid for: learningmyway.space, www.learningmyway.space

# No manual certificate management needed!
```

---

## 🏢 Enterprise GLB Use Cases

### **E-commerce Platform**
```yaml
Architecture:
  - GLB with CDN for product images/CSS
  - WAF protection against attacks
  - Auto-scaling for traffic spikes
  - Multi-region for global customers
  
Traffic Patterns:
  - Normal: 1,000 requests/minute
  - Sale events: 50,000 requests/minute
  - Geographic: 60% US, 25% Europe, 15% Asia
```

### **SaaS Application**
```yaml
Architecture:
  - Path-based routing (/api, /app, /admin)
  - Different backends for different services
  - Rate limiting per customer tier
  - Health checks for service availability
  
Routing Rules:
  /api/* → API backend (Node.js)
  /app/* → Frontend backend (React)
  /admin/* → Admin backend (Django)
```

### **Media Streaming Service**
```yaml
Architecture:
  - GLB for API endpoints
  - CDN for video content delivery
  - Geographic content restrictions
  - Adaptive bitrate based on location
  
Performance:
  - 99.9% uptime SLA
  - <100ms API response time
  - Global content delivery
```

---

## 🔧 Testing Your GLB Setup

### **Test Load Balancing**
```bash
# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test HTTP access
curl -H "Host: learningmyway.space" http://$LB_IP/
# Should return web page from one of your instances

# Test multiple requests to see load balancing
for i in {1..10}; do
  curl -s -H "Host: learningmyway.space" http://$LB_IP/ | grep "Instance ID"
done
# Should see different instance IDs (load balancing in action)
```

### **Test Health Checks**
```bash
# Check health check status
gcloud compute backend-services get-health web-backend --global

# Simulate instance failure
gcloud compute instances stop web-instance-1 --zone=us-central1-a

# Verify traffic still works (failover)
curl -H "Host: learningmyway.space" http://$LB_IP/
# Should still work, served by remaining healthy instance
```

### **Test SSL/HTTPS**
```bash
# Test HTTPS (after DNS is configured)
curl -I https://learningmyway.space/
# Should return 200 OK with SSL certificate info

# Test SSL certificate details
openssl s_client -connect learningmyway.space:443 -servername learningmyway.space
# Shows certificate details, issuer, expiry
```

### **Test CDN Caching**
```bash
# First request (cache miss)
curl -I https://learningmyway.space/images/logo.png
# X-Cache: MISS

# Second request (cache hit)
curl -I https://learningmyway.space/images/logo.png  
# X-Cache: HIT
# Age: 30 (seconds since cached)
```

---

## 📊 GLB Monitoring & Metrics

### **Key Metrics to Monitor**
```yaml
Request Metrics:
  - Requests per second
  - Response latency (50th, 95th, 99th percentile)
  - Error rate (4xx, 5xx responses)
  
Backend Metrics:
  - Backend utilization
  - Health check success rate
  - Connection count
  
CDN Metrics:
  - Cache hit ratio
  - Origin requests
  - Bandwidth usage
```

### **Monitoring Commands**
```bash
# View load balancer logs
gcloud logging read "resource.type=http_load_balancer" --limit=10

# Monitor backend health
gcloud compute backend-services get-health web-backend --global

# Check SSL certificate status
gcloud compute ssl-certificates describe web-ssl-cert --global
```

---

## 🎯 GLB Best Practices

### **Performance Optimization**
```yaml
1. Enable CDN for static content
2. Use appropriate health check intervals
3. Configure connection draining
4. Set proper timeout values
5. Use session affinity when needed
```

### **Security Best Practices**
```yaml
1. Always use HTTPS in production
2. Implement proper WAF rules
3. Use managed SSL certificates
4. Configure appropriate firewall rules
5. Monitor for unusual traffic patterns
```

### **Cost Optimization**
```yaml
1. Use regional load balancers when global isn't needed
2. Optimize CDN cache policies
3. Right-size backend instances
4. Use preemptible instances for non-critical workloads
5. Monitor and optimize data transfer costs
```

---

## 🔄 Legacy Section: How Firewall & WAF Work Together

### **Traffic Flow with Both Protections**

```
Internet Request → Cloud Armor WAF → VPC Firewall → Load Balancer → Web Server
```

#### **Example Attack Scenario:**

**1. DDoS Attack:**
```bash
# Attacker sends 1000 requests/second
for i in {1..1000}; do curl http://your-site.com & done

# WAF Response:
# - First 100 requests: Allowed
# - Requests 101+: HTTP 429 (Rate limited)
# - IP banned for 10 minutes

# Firewall: Still allows HTTP traffic (port 80)
# But WAF blocks the abuse at application layer
```

**2. Port Scan Attack:**
```bash
# Attacker scans for open ports
nmap -p 1-65535 your-server-ip

# Firewall Response:
# - Port 80: Open (allowed by firewall)
# - Port 443: Open (allowed by firewall)  
# - Port 22: Closed (only from Cloud Shell)
# - All other ports: Closed (deny-all rule)

# WAF: Not involved (operates only on HTTP/HTTPS)
```

**3. SQL Injection via Web:**
```bash
# Attacker tries SQL injection
curl "http://your-site.com/login?user=admin'--"

# Firewall: Allows (valid HTTP on port 80)
# WAF: Blocks (detects SQL injection pattern)
# Result: HTTP 403 Forbidden
```

---

## 📊 Real-World Use Cases

### **E-commerce Website**
```yaml
Firewall Rules:
  - Allow HTTP/HTTPS from internet
  - Allow SSH from office IP only
  - Block all other ports
  - Internal communication for microservices

WAF Rules:
  - Rate limiting: 200 requests/minute per IP
  - Block countries with high fraud rates
  - Protect against OWASP Top 10 attacks
  - Special rules for payment endpoints
```

### **API Service**
```yaml
Firewall Rules:
  - Allow HTTPS only (no HTTP)
  - Restrict SSH to bastion host
  - Database access from app tier only

WAF Rules:
  - Strict rate limiting: 100 API calls/minute
  - Require proper Content-Type headers
  - Block requests without API keys
  - Monitor for unusual patterns
```

### **Corporate Application**
```yaml
Firewall Rules:
  - Allow HTTPS from corporate network
  - VPN access for remote workers
  - No direct internet access to database

WAF Rules:
  - Geographic restriction to company countries
  - Integration with corporate identity provider
  - Advanced threat detection
  - Compliance logging
```

---

## 🔧 Testing Your Security

### **Test Firewall Rules**
```bash
# Test HTTP access (should work)
curl -I http://$(terraform output -raw load_balancer_ip)

# Test direct instance access (should fail)
curl -I http://INSTANCE_INTERNAL_IP

# Test SSH from Cloud Shell (should work)
gcloud compute ssh bastion-host --zone=us-central1-a

# Test SSH from internet (should fail)
ssh user@BASTION_EXTERNAL_IP
```

### **Test WAF Rules**
```bash
# Test rate limiting
for i in {1..150}; do 
  curl -s -o /dev/null -w "%{http_code}\n" http://$(terraform output -raw load_balancer_ip)
done
# Should see 200s then 429s

# Test XSS protection
curl "http://$(terraform output -raw load_balancer_ip)/?test=<script>alert('xss')</script>"
# Should return 403

# Test SQL injection protection
curl "http://$(terraform output -raw load_balancer_ip)/?id=1' OR '1'='1"
# Should return 403
```

---

## 📈 Monitoring & Logging

### **Firewall Logs**
```bash
# View firewall logs
gcloud logging read "resource.type=gce_firewall_rule" --limit=10

# Monitor blocked traffic
gcloud logging read "resource.type=gce_firewall_rule AND jsonPayload.disposition=DENIED" --limit=10
```

### **WAF Logs**
```bash
# View Cloud Armor logs
gcloud logging read "resource.type=http_load_balancer" --limit=10

# Monitor blocked requests
gcloud logging read "resource.type=http_load_balancer AND jsonPayload.statusDetails=denied_by_security_policy" --limit=10
```

---

## 🎯 Key Takeaways

### **Global Load Balancer (Traffic Distribution)**
- ✅ **Controls**: Traffic routing, SSL termination, health checks
- ✅ **Protects**: Against single points of failure
- ✅ **Provides**: High availability, global reach, auto-scaling
- ✅ **Performance**: CDN caching, edge locations, anycast IP

### **Firewall (Network Security)**
- ✅ **Controls**: IP addresses, ports, protocols
- ✅ **Protects**: Network infrastructure
- ✅ **Blocks**: Port scans, unauthorized access
- ✅ **Fast**: Minimal latency impact

### **WAF (Application Security)**  
- ✅ **Controls**: HTTP content, patterns, behavior
- ✅ **Protects**: Web applications
- ✅ **Blocks**: OWASP Top 10, DDoS, bots
- ✅ **Smart**: Context-aware decisions

### **Together They Provide**
- 🌐 **Global Reach**: Anycast IP with worldwide edge locations
- 🛡️ **Defense in Depth**: Multiple security layers (GLB + WAF + Firewall)
- 🔒 **Comprehensive Protection**: Network + Application + Distribution
- 📊 **Detailed Logging**: Full visibility across all layers
- ⚡ **High Performance**: CDN caching + SSL offloading + load balancing
- 🔄 **Auto-Healing**: Health checks + failover + auto-scaling

Your project implements enterprise-grade architecture with global load balancing, application security, and network protection! 🚀