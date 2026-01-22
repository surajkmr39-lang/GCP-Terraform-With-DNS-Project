# 🔧 GCP DNS Lab - Troubleshooting Guide

## 🚨 Quick Problem Solver

**Having issues?** Use this guide to diagnose and fix common problems quickly.

---

## 📋 Pre-Deployment Checklist

Before running `terraform apply`, verify:

- [ ] **GCP Project exists** and billing is enabled
- [ ] **APIs are enabled** (or will be auto-enabled)
- [ ] **gcloud CLI authenticated**: `gcloud auth list`
- [ ] **Terraform installed**: `terraform --version`
- [ ] **terraform.tfvars configured** with your project ID
- [ ] **Sufficient quotas** in your GCP project

---

## 🔍 Diagnostic Commands

### **Check Terraform State**
```bash
# List all resources
terraform state list

# Show specific resource details
terraform state show google_compute_network.vpc_network

# Refresh state from GCP
terraform refresh
```

### **Check GCP Resources**
```bash
# List VPC networks
gcloud compute networks list

# List instances
gcloud compute instances list

# List DNS zones
gcloud dns managed-zones list

# Check firewall rules
gcloud compute firewall-rules list
```

### **Test Connectivity**
```bash
# Test DNS resolution
nslookup web-1.internal.example.com
dig app-1.internal.example.com

# Test HTTP connectivity
curl -I http://LOAD_BALANCER_IP
curl -v https://www.example.com

# Test SSH connectivity
gcloud compute ssh bastion-host --zone=us-central1-a
```

---

## ❌ Common Errors and Solutions

### **1. API Not Enabled**

**Error Message:**
```
Error: Error creating Network: googleapi: Error 403: 
Compute Engine API has not been used in project PROJECT_ID
```

**Solution:**
```bash
# Enable required APIs manually
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com

# Or wait for Terraform to enable them automatically
```

### **2. Insufficient Permissions**

**Error Message:**
```
Error: Error creating instance: googleapi: Error 403: 
Required 'compute.instances.create' permission
```

**Solutions:**
```bash
# Check current permissions
gcloud projects get-iam-policy PROJECT_ID

# Ensure you have Editor or Owner role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/editor"
```

### **3. Quota Exceeded**

**Error Message:**
```
Error: Error creating instance: googleapi: Error 403: 
Quota 'CPUS' exceeded. Limit: 8.0 in region us-central1
```

**Solutions:**
```bash
# Check current quotas
gcloud compute project-info describe --project=PROJECT_ID

# Request quota increase in GCP Console
# Or reduce instance count in terraform.tfvars
web_instance_count = 1
app_instance_count = 1
```

### **4. Resource Already Exists**

**Error Message:**
```
Error: Error creating Network: googleapi: Error 409: 
The resource 'projects/PROJECT_ID/global/networks/shared-vpc-network' already exists
```

**Solutions:**
```bash
# Import existing resource
terraform import google_compute_network.vpc_network projects/PROJECT_ID/global/networks/shared-vpc-network

# Or destroy existing resource
gcloud compute networks delete shared-vpc-network

# Or use different names in variables.tf
```

### **5. DNS Zone Creation Failed**

**Error Message:**
```
Error: Error creating ManagedZone: googleapi: Error 409: 
The managed zone 'private-zone' already exists
```

**Solutions:**
```bash
# List existing DNS zones
gcloud dns managed-zones list

# Delete conflicting zone
gcloud dns managed-zones delete private-zone

# Or import existing zone
terraform import google_dns_managed_zone.private_zone projects/PROJECT_ID/managedZones/private-zone
```

### **6. Load Balancer Health Check Failing**

**Error Message:**
```
Backend service backend is unhealthy
```

**Solutions:**
```bash
# Check instance health
gcloud compute backend-services get-health web-backend --global

# Check firewall rules for health check
gcloud compute firewall-rules list --filter="name:health-check"

# SSH to instance and check service
gcloud compute ssh web-1 --zone=us-central1-a
sudo systemctl status nginx
curl localhost/health
```

### **7. SSH Connection Issues**

**Error Message:**
```
Permission denied (publickey)
```

**Solutions:**
```bash
# Generate SSH key if not exists
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Add public key to terraform.tfvars
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E... your_email@example.com"

# Use gcloud SSH (automatically manages keys)
gcloud compute ssh bastion-host --zone=us-central1-a

# Check instance metadata
gcloud compute instances describe bastion-host --zone=us-central1-a
```

---

## 🔧 Instance-Specific Issues

### **Web Server Not Responding**

**Diagnosis:**
```bash
# SSH to web server via bastion
gcloud compute ssh bastion-host --zone=us-central1-a
gcloud compute ssh web-1 --zone=us-central1-a --tunnel-through-iap

# Check Nginx status
sudo systemctl status nginx
sudo nginx -t

# Check logs
sudo tail -f /var/log/nginx/error.log
sudo journalctl -u nginx -f
```

**Common Fixes:**
```bash
# Restart Nginx
sudo systemctl restart nginx

# Fix configuration
sudo nginx -t
sudo systemctl reload nginx

# Check disk space
df -h
```

### **App Server Issues**

**Diagnosis:**
```bash
# SSH to app server
gcloud compute ssh app-1 --zone=us-central1-a --tunnel-through-iap

# Check Node.js application
sudo -u ubuntu pm2 status
sudo -u ubuntu pm2 logs

# Test application directly
curl localhost:3000/health
```

**Common Fixes:**
```bash
# Restart application
sudo -u ubuntu pm2 restart dns-lab-app

# Check application logs
sudo -u ubuntu pm2 logs dns-lab-app

# Restart PM2
sudo -u ubuntu pm2 kill
sudo -u ubuntu pm2 start ecosystem.config.js
```

### **Database Connection Issues**

**Diagnosis:**
```bash
# SSH to database server
gcloud compute ssh db-1 --zone=us-central1-a --tunnel-through-iap

# Check PostgreSQL status
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"

# Check connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

**Common Fixes:**
```bash
# Restart PostgreSQL
sudo systemctl restart postgresql

# Check configuration
sudo -u postgres psql -c "SHOW config_file;"
sudo nano /etc/postgresql/14/main/postgresql.conf

# Check disk space for data directory
df -h /var/lib/postgresql-data
```

---

## 🌐 DNS Troubleshooting

### **Private DNS Not Resolving**

**Diagnosis:**
```bash
# From any instance in VPC
nslookup web-1.internal.example.com
dig web-1.internal.example.com

# Check DNS policy
gcloud dns policies list
```

**Solutions:**
```bash
# Verify DNS zone exists
gcloud dns managed-zones describe private-zone

# Check DNS records
gcloud dns record-sets list --zone=private-zone

# Verify VPC is associated with DNS zone
gcloud dns managed-zones describe private-zone --format="value(privateVisibilityConfig.networks)"
```

### **Public DNS Issues**

**Diagnosis:**
```bash
# Test from external location
nslookup www.example.com 8.8.8.8
dig www.example.com @8.8.8.8

# Check name servers
gcloud dns managed-zones describe public-zone --format="value(nameServers)"
```

**Solutions:**
```bash
# Verify public zone configuration
gcloud dns managed-zones describe public-zone

# Check if domain is properly configured with registrar
# Name servers should match GCP DNS zone name servers
```

---

## 🔥 Firewall Issues

### **Traffic Being Blocked**

**Diagnosis:**
```bash
# List firewall rules
gcloud compute firewall-rules list

# Check specific rule
gcloud compute firewall-rules describe allow-http

# Check VPC flow logs (if enabled)
gcloud logging read "resource.type=gce_subnetwork"
```

**Solutions:**
```bash
# Verify firewall rule exists and is correct
gcloud compute firewall-rules create test-allow-http \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags web-server

# Check instance tags
gcloud compute instances describe web-1 --zone=us-central1-a --format="value(tags.items)"
```

---

## 📊 Monitoring and Logging

### **Enable Detailed Logging**

```bash
# Enable VPC Flow Logs
gcloud compute networks subnets update subnet-web \
  --region=us-central1 \
  --enable-flow-logs

# Enable firewall logging
gcloud compute firewall-rules update allow-http \
  --enable-logging

# View logs in Cloud Console or CLI
gcloud logging read "resource.type=gce_instance" --limit=50
```

### **Performance Issues**

**Check Resource Usage:**
```bash
# On any instance
htop
df -h
free -h
iostat -x 1

# Check network connectivity
ping google.com
traceroute google.com
```

---

## 🚨 Emergency Procedures

### **Complete Reset**

If everything is broken:
```bash
# Destroy all resources
terraform destroy -auto-approve

# Clean up any remaining resources manually
gcloud compute instances list
gcloud compute networks list
gcloud dns managed-zones list

# Start fresh
terraform apply
```

### **Partial Reset**

To reset specific components:
```bash
# Target specific resources
terraform destroy -target=module.instances
terraform apply -target=module.instances

# Or recreate specific instances
terraform taint google_compute_instance.web_instances[0]
terraform apply
```

---

## 📞 Getting Help

### **Terraform Issues**
1. Check [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
2. Search [Terraform GitHub Issues](https://github.com/hashicorp/terraform-provider-google/issues)
3. Use `terraform plan` to see what will change

### **GCP Issues**
1. Check [GCP Status Page](https://status.cloud.google.com/)
2. Review [GCP Documentation](https://cloud.google.com/docs)
3. Use [GCP Support](https://cloud.google.com/support) if you have a support plan

### **Application Issues**
1. Check application logs in `/var/log/`
2. Use `journalctl` for systemd service logs
3. Test components individually

---

## 🎯 Prevention Tips

### **Before Deployment**
- Always run `terraform plan` first
- Test in a development project first
- Keep backups of working configurations
- Document any customizations

### **During Operation**
- Monitor resource usage regularly
- Set up billing alerts
- Keep Terraform state backed up
- Regular security updates

### **Best Practices**
- Use version control for Terraform code
- Implement proper change management
- Regular testing of disaster recovery
- Keep documentation updated

---

## 📝 Logging Your Issues

When asking for help, include:

1. **Error message** (full text)
2. **Terraform version**: `terraform --version`
3. **GCP provider version** (from terraform init output)
4. **Steps to reproduce** the issue
5. **Relevant configuration** (sanitized)
6. **What you've already tried**

This information helps others help you more effectively!

Remember: Every error is a learning opportunity. Don't get discouraged - even experienced cloud engineers encounter these issues regularly!