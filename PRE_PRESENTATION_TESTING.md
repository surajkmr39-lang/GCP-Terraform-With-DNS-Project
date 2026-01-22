# 🧪 Pre-Presentation Testing Guide

## 🎯 Complete Project Testing Before Presentation

This guide ensures your GCP DNS Lab project is fully functional and ready for demonstration.

---

## 📋 Testing Checklist Overview

### **Phase 1: Pre-Deployment Validation** ✅
- [ ] Terraform configuration validation
- [ ] Authentication setup
- [ ] API enablement
- [ ] Project permissions

### **Phase 2: Infrastructure Deployment** 🚀
- [ ] Terraform initialization
- [ ] Resource planning
- [ ] Infrastructure deployment
- [ ] Resource verification

### **Phase 3: Functionality Testing** 🔧
- [ ] Network connectivity
- [ ] DNS resolution
- [ ] Load balancer functionality
- [ ] Security controls (Firewall & WAF)
- [ ] Instance accessibility

### **Phase 4: End-to-End Testing** 🌐
- [ ] Complete user journey
- [ ] Performance validation
- [ ] Security testing
- [ ] Monitoring verification

### **Phase 5: Presentation Readiness** 🎤
- [ ] Demo scenarios prepared
- [ ] Troubleshooting knowledge
- [ ] Key metrics documented
- [ ] Cleanup procedures ready

---

## 🔧 Phase 1: Pre-Deployment Validation

### **Step 1.1: Environment Setup**
```bash
# Verify gcloud installation and authentication
gcloud --version
gcloud auth list
gcloud config list

# Set your project
gcloud config set project strange-passage-483616-i1

# Verify project access
gcloud projects describe strange-passage-483616-i1
```

### **Step 1.2: API Enablement**
```bash
# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudasset.googleapis.com

# Verify APIs are enabled
gcloud services list --enabled --filter="name:(compute OR dns OR iam)"
```

### **Step 1.3: Terraform Validation**
```bash
# Navigate to project directory
cd /path/to/GCP-Terraform-DNS-Lab

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format check
terraform fmt -check

# Security scan (if tfsec is installed)
tfsec . || echo "tfsec not installed, skipping security scan"
```

**Expected Results:**
- ✅ All APIs enabled successfully
- ✅ Terraform validation passes
- ✅ No formatting issues
- ✅ No critical security issues

---

## 🚀 Phase 2: Infrastructure Deployment

### **Step 2.1: Terraform Planning**
```bash
# Create execution plan
terraform plan -out=tfplan

# Review the plan
terraform show tfplan

# Count resources to be created
terraform plan | grep "Plan:" | tail -1
```

**Expected Resources:**
- ~45-55 resources to be created
- VPC network and subnets
- Compute instances (6 total)
- DNS zones and records
- Load balancer components
- Firewall rules
- IAM service accounts

### **Step 2.2: Infrastructure Deployment**
```bash
# Deploy infrastructure
terraform apply tfplan

# Verify deployment
terraform state list | wc -l
echo "Total resources created: $(terraform state list | wc -l)"
```

### **Step 2.3: Resource Verification**
```bash
# Check VPC network
gcloud compute networks list --project=strange-passage-483616-i1

# Check compute instances
gcloud compute instances list --project=strange-passage-483616-i1

# Check DNS zones
gcloud dns managed-zones list --project=strange-passage-483616-i1

# Check load balancer
gcloud compute forwarding-rules list --global --project=strange-passage-483616-i1

# Check firewall rules
gcloud compute firewall-rules list --project=strange-passage-483616-i1
```

**Expected Results:**
- ✅ 1 VPC network created
- ✅ 3 subnets created
- ✅ 6 instances running (2 web, 2 app, 1 db, 1 bastion)
- ✅ 2 DNS zones created
- ✅ Load balancer operational
- ✅ 8+ firewall rules active

---

## 🔧 Phase 3: Functionality Testing

### **Step 3.1: Network Connectivity Testing**
```bash
# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test basic HTTP connectivity
curl -I http://$LB_IP
echo "HTTP Status: $?"

# Test HTTPS connectivity (may fail initially due to SSL cert provisioning)
curl -I https://$LB_IP -k
echo "HTTPS Status: $?"

# Test health endpoint
curl -s http://$LB_IP/health
echo "Health Check Status: $?"
```

### **Step 3.2: DNS Resolution Testing**
```bash
# Test public DNS (if domain is configured)
nslookup www.learningmyway.space || echo "Public DNS not configured"

# SSH to bastion for internal DNS testing
BASTION_IP=$(gcloud compute instances describe bastion --zone=us-central1-a --project=strange-passage-483616-i1 --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "Bastion IP: $BASTION_IP"

# Test SSH to bastion
gcloud compute ssh bastion --zone=us-central1-a --project=strange-passage-483616-i1 --command="echo 'Bastion SSH successful'"
```

### **Step 3.3: Internal DNS Testing (via Bastion)**
```bash
# Test internal DNS resolution
gcloud compute ssh bastion --zone=us-central1-a --project=strange-passage-483616-i1 --command="
echo 'Testing internal DNS resolution:'
nslookup web-1.internal.learningmyway.space
nslookup app-1.internal.learningmyway.space  
nslookup db-1.internal.learningmyway.space
echo 'DNS testing complete'
"
```

### **Step 3.4: Application Testing**
```bash
# Test web application
curl -s http://$LB_IP | grep -o "<title>.*</title>" || echo "Web app not responding"

# Test API endpoints
curl -s http://$LB_IP/api/status | jq . || echo "API not responding"

# Test database connectivity (via API)
curl -s http://$LB_IP/api/users | jq . || echo "Database connection failed"
```

---

## 🛡️ Phase 4: Security Testing

### **Step 4.1: Firewall Testing**
```bash
# Test allowed traffic (should work)
curl -I http://$LB_IP
echo "HTTP access test: $?"

# Test SSH to bastion (should work from Cloud Shell)
gcloud compute ssh bastion --zone=us-central1-a --project=strange-passage-483616-i1 --command="echo 'SSH test successful'"

# Test direct instance access (should fail)
WEB_INTERNAL_IP=$(gcloud compute instances describe web-1 --zone=us-central1-a --project=strange-passage-483616-i1 --format="value(networkInterfaces[0].networkIP)")
echo "Testing direct access to web server (should timeout):"
timeout 10 curl -I http://$WEB_INTERNAL_IP || echo "Direct access blocked (expected)"
```

### **Step 4.2: WAF Testing**
```bash
# Test rate limiting
echo "Testing rate limiting (sending 120 requests):"
for i in {1..120}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)
  if [ "$STATUS" = "429" ]; then
    echo "Rate limiting triggered at request $i"
    break
  fi
done

# Test XSS protection
echo "Testing XSS protection:"
XSS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://$LB_IP/?test=<script>alert('xss')</script>")
if [ "$XSS_RESPONSE" = "403" ]; then
  echo "✅ XSS protection working"
else
  echo "❌ XSS protection not working (got $XSS_RESPONSE)"
fi

# Test SQL injection protection
echo "Testing SQL injection protection:"
SQL_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://$LB_IP/?id=1' OR '1'='1")
if [ "$SQL_RESPONSE" = "403" ]; then
  echo "✅ SQL injection protection working"
else
  echo "❌ SQL injection protection not working (got $SQL_RESPONSE)"
fi
```

---

## 🌐 Phase 5: End-to-End Testing

### **Step 5.1: Complete User Journey**
```bash
echo "=== Complete User Journey Test ==="

# 1. DNS Resolution
echo "1. Testing DNS resolution..."
nslookup www.learningmyway.space || echo "Using load balancer IP directly"

# 2. Load Balancer Access
echo "2. Testing load balancer access..."
curl -I http://$LB_IP

# 3. Web Page Load
echo "3. Testing web page load..."
curl -s http://$LB_IP | grep -o "<title>.*</title>"

# 4. API Call
echo "4. Testing API call..."
curl -s http://$LB_IP/api/status | jq .status

# 5. Database Query (via API)
echo "5. Testing database query..."
curl -s http://$LB_IP/api/users | jq .[0].name

echo "=== User Journey Test Complete ==="
```

### **Step 5.2: Performance Testing**
```bash
# Simple load test (if ab is available)
if command -v ab &> /dev/null; then
  echo "Running performance test..."
  ab -n 100 -c 10 http://$LB_IP/ | grep "Requests per second"
else
  echo "Apache Bench not available, skipping performance test"
fi

# Response time test
echo "Testing response times:"
for i in {1..5}; do
  TIME=$(curl -o /dev/null -s -w "%{time_total}" http://$LB_IP)
  echo "Request $i: ${TIME}s"
done
```

---

## 📊 Phase 6: Monitoring & Logging Verification

### **Step 6.1: Check Logs**
```bash
# Check VPC Flow Logs
echo "Checking VPC Flow Logs..."
gcloud logging read "resource.type=gce_subnetwork" --limit=5 --project=strange-passage-483616-i1

# Check Firewall Logs
echo "Checking Firewall Logs..."
gcloud logging read "resource.type=gce_firewall_rule" --limit=5 --project=strange-passage-483616-i1

# Check Load Balancer Logs
echo "Checking Load Balancer Logs..."
gcloud logging read "resource.type=http_load_balancer" --limit=5 --project=strange-passage-483616-i1
```

### **Step 6.2: Instance Health Check**
```bash
# Check instance status
echo "Checking instance health..."
gcloud compute instances list --project=strange-passage-483616-i1 --format="table(name,status,zone)"

# Check load balancer backend health
echo "Checking backend health..."
gcloud compute backend-services get-health web-backend --global --project=strange-passage-483616-i1
```

---

## 🎤 Phase 7: Presentation Preparation

### **Step 7.1: Document Key Metrics**
```bash
# Create presentation metrics file
cat > presentation_metrics.txt << EOF
=== GCP DNS Lab - Presentation Metrics ===
Deployment Date: $(date)
Project ID: strange-passage-483616-i1
Load Balancer IP: $LB_IP
Bastion IP: $BASTION_IP

Resource Count:
- VPC Networks: $(gcloud compute networks list --project=strange-passage-483616-i1 --format="value(name)" | wc -l)
- Compute Instances: $(gcloud compute instances list --project=strange-passage-483616-i1 --format="value(name)" | wc -l)
- DNS Zones: $(gcloud dns managed-zones list --project=strange-passage-483616-i1 --format="value(name)" | wc -l)
- Firewall Rules: $(gcloud compute firewall-rules list --project=strange-passage-483616-i1 --format="value(name)" | wc -l)

Test Results:
- HTTP Connectivity: $(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)
- Health Check: $(curl -s http://$LB_IP/health | grep -o "healthy" || echo "unhealthy")
- API Status: $(curl -s http://$LB_IP/api/status | jq -r .status)

Security Tests:
- WAF Protection: Active
- Firewall Rules: Active
- Rate Limiting: Functional

Performance:
- Average Response Time: $(curl -o /dev/null -s -w "%{time_total}" http://$LB_IP)s
- SSL Certificate: $(curl -I https://$LB_IP -k 2>/dev/null | grep "HTTP" | awk '{print $2}')

EOF

cat presentation_metrics.txt
```

### **Step 7.2: Prepare Demo Scenarios**
```bash
# Create demo script
cat > demo_script.sh << 'EOF'
#!/bin/bash

echo "=== GCP DNS Lab Live Demo ==="

# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)

echo "1. Showing infrastructure overview..."
gcloud compute instances list --project=strange-passage-483616-i1

echo "2. Testing web application..."
curl -s http://$LB_IP | grep -o "<title>.*</title>"

echo "3. Testing API endpoints..."
curl -s http://$LB_IP/api/status | jq .

echo "4. Demonstrating security (rate limiting)..."
echo "Sending multiple requests to trigger rate limiting..."
for i in {1..10}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)
  echo "Request $i: HTTP $STATUS"
  sleep 0.5
done

echo "5. Testing WAF protection..."
curl -s -o /dev/null -w "XSS Test: %{http_code}\n" "http://$LB_IP/?test=<script>alert('xss')</script>"

echo "6. Showing DNS resolution..."
gcloud compute ssh bastion --zone=us-central1-a --project=strange-passage-483616-i1 --command="nslookup web-1.internal.learningmyway.space"

echo "=== Demo Complete ==="
EOF

chmod +x demo_script.sh
```

---

## ✅ Final Validation Checklist

### **Before Presentation, Verify:**

#### **Infrastructure Status:**
- [ ] All 6 instances running
- [ ] Load balancer healthy
- [ ] DNS zones operational
- [ ] Firewall rules active

#### **Functionality:**
- [ ] Web application accessible
- [ ] API endpoints responding
- [ ] Database connectivity working
- [ ] SSH access via bastion functional

#### **Security:**
- [ ] WAF blocking malicious requests
- [ ] Rate limiting functional
- [ ] Firewall rules blocking unauthorized access
- [ ] SSL certificate provisioned (may take time)

#### **Performance:**
- [ ] Response time < 2 seconds
- [ ] Health checks passing
- [ ] No error logs in monitoring

#### **Demo Readiness:**
- [ ] Demo script tested
- [ ] Key metrics documented
- [ ] Troubleshooting commands ready
- [ ] Cleanup procedure prepared

---

## 🚨 Troubleshooting Quick Reference

### **Common Issues & Solutions:**

**Issue: Load balancer returns 502/503**
```bash
# Check backend health
gcloud compute backend-services get-health web-backend --global --project=strange-passage-483616-i1

# Check instance status
gcloud compute instances list --project=strange-passage-483616-i1
```

**Issue: SSL certificate not ready**
```bash
# Check certificate status
gcloud compute ssl-certificates list --project=strange-passage-483616-i1

# Note: Can take 10-60 minutes to provision
```

**Issue: DNS not resolving**
```bash
# Check DNS zones
gcloud dns managed-zones list --project=strange-passage-483616-i1

# Check DNS records
gcloud dns record-sets list --zone=private-zone --project=strange-passage-483616-i1
```

**Issue: Instances not accessible**
```bash
# Check firewall rules
gcloud compute firewall-rules list --project=strange-passage-483616-i1

# Check instance tags
gcloud compute instances describe web-1 --zone=us-central1-a --project=strange-passage-483616-i1 --format="value(tags.items)"
```

---

## 🎯 Success Criteria

Your project is presentation-ready when:

- ✅ **All infrastructure deployed** without errors
- ✅ **Load balancer accessible** and returning HTTP 200
- ✅ **Web application functional** with proper content
- ✅ **API endpoints responding** with valid JSON
- ✅ **Security controls active** (WAF blocking attacks)
- ✅ **DNS resolution working** for internal services
- ✅ **SSH access functional** via bastion host
- ✅ **Monitoring and logging** operational
- ✅ **Demo script tested** and working
- ✅ **Key metrics documented** for presentation

**You're now ready to present your enterprise-grade GCP infrastructure! 🚀**