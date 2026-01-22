# ✅ GCP DNS Lab Deployment Checklist

## 📋 Pre-Deployment Checklist

### **Project Configuration**
- [ ] **Project ID**: `strange-passage-483616-i1`
- [ ] **Organization**: `315400019148`
- [ ] **Domain**: `learningmyway.space`
- [ ] **Region**: `us-central1`
- [ ] **Zone**: `us-central1-a`

### **Authentication Setup**
- [ ] Google Cloud SDK installed
- [ ] Authenticated with gcloud: `gcloud auth login`
- [ ] Application default credentials: `gcloud auth application-default login`
- [ ] Project set: `gcloud config set project strange-passage-483616-i1`
- [ ] Terraform installed (>= 1.0)

### **API Enablement**
```bash
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudasset.googleapis.com
```

### **Terraform Configuration**
- [ ] `terraform.tfvars` file created with your project details
- [ ] SSH public key added (optional)
- [ ] DNS domain names configured
- [ ] Resource labels customized

---

## 🚀 Deployment Steps

### **Step 1: Initialize Terraform**
```bash
terraform init
```
**Expected Output**: 
- Provider downloads
- Backend initialization
- Module downloads

### **Step 2: Validate Configuration**
```bash
terraform validate
```
**Expected Output**: `Success! The configuration is valid.`

### **Step 3: Plan Deployment**
```bash
terraform plan
```
**Review the plan for**:
- [ ] Correct project ID
- [ ] Proper resource names
- [ ] Expected resource counts
- [ ] DNS zone configurations

### **Step 4: Deploy Infrastructure**
```bash
terraform apply
```
**Deployment will create**:
- [ ] VPC network with 3 subnets
- [ ] 5 compute instances (2 web, 2 app, 1 db, 1 bastion)
- [ ] DNS zones (private and public)
- [ ] Load balancer with health checks
- [ ] Firewall rules
- [ ] IAM service accounts
- [ ] Cloud Armor WAF policy

---

## 🔍 Post-Deployment Verification

### **Infrastructure Verification**
```bash
# Check VPC
gcloud compute networks list --project=strange-passage-483616-i1

# Check instances
gcloud compute instances list --project=strange-passage-483616-i1

# Check DNS zones
gcloud dns managed-zones list --project=strange-passage-483616-i1

# Check load balancer
gcloud compute forwarding-rules list --global --project=strange-passage-483616-i1
```

### **Connectivity Tests**
```bash
# Get load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)
echo "Load Balancer IP: $LB_IP"

# Test HTTP connectivity
curl -I http://$LB_IP

# Test health endpoint
curl http://$LB_IP/health
```

### **DNS Resolution Tests**
```bash
# Test public DNS (if domain is configured)
nslookup www.learningmyway.space

# SSH to bastion and test private DNS
gcloud compute ssh bastion --zone=us-central1-a --project=strange-passage-483616-i1
# From bastion:
nslookup web-1.internal.learningmyway.space
```

---

## 📊 Resource Summary

### **Compute Resources**
| Resource Type | Count | Machine Type | Purpose |
|---------------|-------|--------------|---------|
| Web Servers | 2 | e2-medium | Frontend/Nginx |
| App Servers | 2 | e2-medium | Backend/Node.js |
| Database | 1 | e2-standard-2 | PostgreSQL |
| Bastion Host | 1 | e2-micro | SSH Gateway |

### **Network Resources**
| Resource | Configuration |
|----------|---------------|
| VPC Network | `shared-vpc-network` |
| Web Subnet | `10.0.1.0/24` |
| App Subnet | `10.0.2.0/24` |
| DB Subnet | `10.0.3.0/24` |
| Load Balancer | Global HTTP(S) |

### **DNS Configuration**
| Zone Type | Domain | Purpose |
|-----------|--------|---------|
| Private | `internal.learningmyway.space` | Internal service discovery |
| Public | `learningmyway.space` | External domain resolution |

---

## 💰 Cost Estimation

### **Monthly Cost Breakdown** (Approximate)
- **Compute Instances**: ~$50-80
- **Load Balancer**: ~$18-25
- **Persistent Disks**: ~$10-15
- **Network Egress**: ~$5-10
- **DNS Queries**: ~$0.50
- **Total Estimated**: ~$85-130/month

### **Cost Optimization Tips**
- Use preemptible instances for development
- Stop instances when not in use
- Monitor usage with billing alerts
- Set up budget alerts

---

## 🔧 Troubleshooting

### **Common Issues**

**Issue**: API not enabled
```bash
# Solution: Enable required APIs
gcloud services enable compute.googleapis.com --project=strange-passage-483616-i1
```

**Issue**: Insufficient permissions
```bash
# Solution: Check IAM permissions
gcloud projects get-iam-policy strange-passage-483616-i1
```

**Issue**: Quota exceeded
```bash
# Solution: Check quotas
gcloud compute project-info describe --project=strange-passage-483616-i1
```

**Issue**: DNS resolution not working
```bash
# Solution: Check DNS zones and records
gcloud dns managed-zones list --project=strange-passage-483616-i1
gcloud dns record-sets list --zone=private-zone --project=strange-passage-483616-i1
```

---

## 🧹 Cleanup

### **Destroy Resources**
```bash
# Destroy all resources
terraform destroy

# Confirm destruction
# Type 'yes' when prompted
```

### **Verify Cleanup**
```bash
# Check for remaining resources
gcloud compute instances list --project=strange-passage-483616-i1
gcloud compute networks list --project=strange-passage-483616-i1
gcloud dns managed-zones list --project=strange-passage-483616-i1
```

---

## 📝 Deployment Log

### **Deployment Information**
- **Date**: ___________
- **Deployed by**: ___________
- **Terraform Version**: ___________
- **Deployment Duration**: ___________
- **Issues Encountered**: ___________

### **Resource URLs**
- **Load Balancer IP**: ___________
- **Bastion Host External IP**: ___________
- **GCP Console URL**: https://console.cloud.google.com/compute/instances?project=strange-passage-483616-i1

### **Next Steps**
- [ ] Configure domain DNS records (if using real domain)
- [ ] Set up monitoring and alerting
- [ ] Configure backup policies
- [ ] Implement CI/CD pipeline
- [ ] Security hardening review

---

## 🎯 Success Criteria

Your deployment is successful when:
- ✅ All Terraform resources created without errors
- ✅ Load balancer returns HTTP 200 response
- ✅ All instances are running and healthy
- ✅ DNS resolution works for internal services
- ✅ SSH access works through bastion host
- ✅ No security vulnerabilities in initial scan

**Congratulations! You've successfully deployed a production-ready GCP infrastructure with Terraform!**