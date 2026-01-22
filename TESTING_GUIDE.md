# 🧪 GCP DNS Lab - Testing Guide

## 🎯 Complete Testing Strategy

This guide provides comprehensive testing procedures to validate every component of your GCP DNS Lab.

---

## 📋 Testing Checklist

### **Pre-Testing Setup**
- [ ] All resources deployed successfully
- [ ] No Terraform errors
- [ ] All instances are running
- [ ] Load balancer shows healthy backends

### **Core Functionality**
- [ ] Web servers responding
- [ ] App servers processing requests
- [ ] Database connectivity working
- [ ] DNS resolution functioning
- [ ] Load balancer distributing traffic

### **Security Features**
- [ ] Firewall rules blocking unauthorized traffic
- [ ] WAF blocking malicious requests
- [ ] SSH access working through bastion
- [ ] Internal communication secured

---

## 🌐 Web Application Testing

### **1. Basic Connectivity Test**

```bash
# Get the load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test HTTP connectivity
curl -I http://$LB_IP
# Expected: HTTP/1.1 200 OK

# Test with custom host header
curl -H "Host: www.example.com" http://$LB_IP
# Expected: HTML page with instance information
```

### **2. Load Balancer Distribution Test**

```bash
# Test multiple requests to see different backends
for i in {1..10}; do
  curl -s http://$LB_IP | grep "Instance:" | head -1
done
# Expected: Should show different instance names (web-1, web-2)
```

### **3. Health Check Validation**

```bash
# Test health endpoint directly
curl http://$LB_IP/health
# Expected: "healthy" response

# Check backend health via GCP
gcloud compute backend-services get-health web-backend --global
# Expected: All backends should be HEALTHY
```

---

## 🔍 DNS Testing

### **4. Private DNS Resolution**

```bash
# SSH to bastion host first
gcloud compute ssh bastion-host --zone=us-central1-a

# From bastion, test private DNS
nslookup web-1.internal.example.com
# Expected: Should resolve to 10.0.1.x

nslookup app-1.internal.example.com
# Expected: Should resolve to 10.0.2.x

nslookup db-1.internal.example.com
# Expected: Should resolve to 10.0.3.x

# Test reverse DNS
nslookup 10.0.1.10
# Expected: Should return web-1.internal.example.com
```

### **5. Public DNS Resolution**

```bash
# Test from external location (your local machine)
nslookup www.example.com
# Expected: Should resolve to load balancer IP

# Test with different DNS servers
dig @8.8.8.8 www.example.com
dig @1.1.1.1 www.example.com
# Expected: Consistent results
```

### **6. DNS Policy Testing**

```bash
# From any instance in VPC, test external resolution
nslookup google.com
# Expected: Should resolve using configured forwarders (8.8.8.8)

# Test DNS logging (check Cloud Logging)
gcloud logging read "resource.type=dns_query" --limit=10
```

---

## 🖥️ Instance-Level Testing

### **7. Web Server Testing**

```bash
# SSH to web server via bastion
gcloud compute ssh web-1 --zone=us-central1-a --tunnel-through-iap

# Test Nginx configuration
sudo nginx -t
# Expected: syntax is ok, test is successful

# Test local web server
curl localhost
# Expected: HTML page with instance info

# Test proxy to app server
curl localhost/api/status
# Expected: JSON response from app server

# Check Nginx logs
sudo tail -f /var/log/nginx/access.log
# Make requests and verify they appear in logs
```

### **8. App Server Testing**

```bash
# SSH to app server
gcloud compute ssh app-1 --zone=us-central1-a --tunnel-through-iap

# Check PM2 status
sudo -u ubuntu pm2 status
# Expected: dns-lab-app should be online

# Test app directly
curl localhost:3000/health
# Expected: JSON health response

curl localhost:3000/api/users
# Expected: JSON array of users

curl localhost:3000/api/metrics
# Expected: System metrics in JSON

# Check app logs
sudo -u ubuntu pm2 logs dns-lab-app
```

### **9. Database Testing**

```bash
# SSH to database server
gcloud compute ssh db-1 --zone=us-central1-a --tunnel-through-iap

# Test PostgreSQL connection
sudo -u postgres psql -c "SELECT version();"
# Expected: PostgreSQL version information

# Test application database
sudo -u postgres psql -d dnslab -c "SELECT * FROM users LIMIT 5;"
# Expected: Sample user data

# Test database connectivity from app server
# From app server:
curl localhost:3000/api/db/test
# Expected: Database connection success message
```

---

## 🔒 Security Testing

### **10. Firewall Rule Testing**

```bash
# Test allowed traffic (should work)
curl -I http://$LB_IP
# Expected: 200 OK

# Test SSH to bastion (should work)
gcloud compute ssh bastion-host --zone=us-central1-a
# Expected: Successful connection

# Test direct access to internal instances (should fail)
# Get internal IP of web server
WEB_IP=$(gcloud compute instances describe web-1 --zone=us-central1-a --format="value(networkInterfaces[0].networkIP)")

# Try to SSH directly (should fail)
ssh $WEB_IP
# Expected: Connection timeout or refused
```

### **11. WAF (Cloud Armor) Testing**

```bash
# Test normal request (should work)
curl http://$LB_IP
# Expected: 200 OK

# Test malicious patterns (should be blocked)
curl "http://$LB_IP/?test=<script>alert('xss')</script>"
# Expected: 403 Forbidden

curl "http://$LB_IP/?test=union+select+*+from+users"
# Expected: 403 Forbidden

# Test rate limiting (make many requests quickly)
for i in {1..150}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://$LB_IP
done
# Expected: Should start returning 429 (Too Many Requests) after ~100 requests
```

### **12. SSH Security Testing**

```bash
# Test SSH key authentication (should work)
gcloud compute ssh bastion-host --zone=us-central1-a
# Expected: Successful login

# Test password authentication (should fail)
# This would require trying to SSH with password, which should be disabled

# Check fail2ban status on bastion
sudo fail2ban-client status sshd
# Expected: Should show fail2ban is active
```

---

## 🔄 End-to-End Testing

### **13. Complete User Journey Test**

```bash
# Simulate a complete user interaction
echo "=== Complete User Journey Test ==="

# 1. DNS Resolution
echo "1. Testing DNS resolution..."
nslookup www.example.com

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
```

### **14. Internal Service Communication Test**

```bash
# From web server, test communication to app server
# SSH to web server first
gcloud compute ssh web-1 --zone=us-central1-a --tunnel-through-iap

# Test DNS resolution of app server
nslookup app-1.internal.example.com
# Expected: Should resolve to app server IP

# Test HTTP communication
curl app-1.internal.example.com/health
# Expected: Health check response

# From app server, test database communication
# SSH to app server
gcloud compute ssh app-1 --zone=us-central1-a --tunnel-through-iap

# Test database connectivity
ping db-1.internal.example.com
# Expected: Should be able to ping

# Test database connection via app
curl localhost:3000/api/db/test
# Expected: Database connection success
```

---

## 📊 Performance Testing

### **15. Load Testing**

```bash
# Simple load test (install apache2-utils if needed)
# apt-get install apache2-utils

# Test with 100 requests, 10 concurrent
ab -n 100 -c 10 http://$LB_IP/
# Expected: Should handle load without errors

# Test API endpoint
ab -n 50 -c 5 http://$LB_IP/api/users
# Expected: Should return consistent responses
```

### **16. Database Performance Test**

```bash
# SSH to database server
gcloud compute ssh db-1 --zone=us-central1-a --tunnel-through-iap

# Test database performance
sudo -u postgres psql -d dnslab -c "
  EXPLAIN ANALYZE SELECT * FROM users WHERE email LIKE '%example%';
"
# Expected: Should show query execution plan and timing
```

---

## 🔧 Automated Testing Scripts

### **17. Create Comprehensive Test Script**

```bash
# Create automated test script
cat > test-lab.sh << 'EOF'
#!/bin/bash

echo "=== GCP DNS Lab Comprehensive Test ==="
echo "Started at: $(date)"

# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test 1: Basic connectivity
echo -n "Test 1 - Basic connectivity: "
if curl -s -I http://$LB_IP | grep -q "200 OK"; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test 2: Health check
echo -n "Test 2 - Health check: "
if curl -s http://$LB_IP/health | grep -q "healthy"; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test 3: API endpoint
echo -n "Test 3 - API endpoint: "
if curl -s http://$LB_IP/api/status | grep -q "running"; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test 4: DNS resolution
echo -n "Test 4 - DNS resolution: "
if nslookup www.example.com > /dev/null 2>&1; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

# Test 5: WAF protection
echo -n "Test 5 - WAF protection: "
if curl -s "http://$LB_IP/?test=<script>" | grep -q "403\|blocked"; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
fi

echo "=== Test completed at: $(date) ==="
EOF

chmod +x test-lab.sh
./test-lab.sh
```

---

## 📈 Monitoring and Observability Testing

### **18. Logging Verification**

```bash
# Check VPC Flow Logs
gcloud logging read "resource.type=gce_subnetwork" --limit=5

# Check Firewall Logs
gcloud logging read "resource.type=gce_firewall_rule" --limit=5

# Check Load Balancer Logs
gcloud logging read "resource.type=http_load_balancer" --limit=5

# Check instance logs
gcloud logging read "resource.type=gce_instance" --limit=5
```

### **19. Metrics Verification**

```bash
# Check if monitoring agent is running on instances
gcloud compute ssh web-1 --zone=us-central1-a --tunnel-through-iap --command="sudo systemctl status google-cloud-ops-agent"

# View metrics in Cloud Console
echo "Check Cloud Monitoring dashboard for:"
echo "- CPU utilization"
echo "- Memory usage"
echo "- Network traffic"
echo "- Disk I/O"
```

---

## 🎯 Test Results Documentation

### **20. Create Test Report**

```bash
# Generate test report
cat > test-report.md << EOF
# GCP DNS Lab Test Report

**Date:** $(date)
**Tester:** $(whoami)

## Test Results Summary

| Test Category | Status | Notes |
|---------------|--------|-------|
| Web Connectivity | ✅ PASS | Load balancer responding |
| DNS Resolution | ✅ PASS | Both private and public working |
| API Endpoints | ✅ PASS | All endpoints returning data |
| Database | ✅ PASS | PostgreSQL accessible |
| Security | ✅ PASS | WAF blocking malicious requests |
| SSH Access | ✅ PASS | Bastion host accessible |

## Detailed Results

### Performance Metrics
- Average response time: XXXms
- Concurrent users supported: XXX
- Database query time: XXXms

### Security Tests
- Firewall rules: All tests passed
- WAF protection: Blocking malicious requests
- SSH hardening: Key-only authentication working

## Recommendations
- Monitor resource usage during peak times
- Consider implementing additional monitoring alerts
- Regular security updates recommended

EOF

echo "Test report generated: test-report.md"
```

---

## 🚨 Troubleshooting Failed Tests

### **If Tests Fail:**

1. **Check Terraform State**
   ```bash
   terraform state list
   terraform plan
   ```

2. **Verify Resource Status**
   ```bash
   gcloud compute instances list
   gcloud compute backend-services get-health web-backend --global
   ```

3. **Check Logs**
   ```bash
   gcloud logging read "severity>=ERROR" --limit=20
   ```

4. **Test Individual Components**
   - Start with basic connectivity
   - Test each tier separately
   - Verify DNS resolution step by step

---

## 🎉 Success Criteria

Your lab is working correctly if:

- ✅ All instances are running and healthy
- ✅ Load balancer shows all backends as healthy
- ✅ Web interface is accessible via load balancer IP
- ✅ API endpoints return valid JSON responses
- ✅ Database queries work through the application
- ✅ Private DNS resolves internal hostnames
- ✅ Public DNS resolves external domains
- ✅ WAF blocks malicious requests
- ✅ SSH access works through bastion host
- ✅ All firewall rules are functioning correctly

**Congratulations!** You've successfully deployed and tested a production-ready, multi-tier cloud application with comprehensive security and monitoring.

---

## 📚 Next Steps

After successful testing:
1. **Explore the GCP Console** to see your resources
2. **Customize the application** to fit your needs
3. **Implement additional monitoring** and alerting
4. **Practice disaster recovery** procedures
5. **Scale the application** by adding more instances

Remember to **destroy resources** when you're done learning to avoid unnecessary costs:
```bash
terraform destroy
```