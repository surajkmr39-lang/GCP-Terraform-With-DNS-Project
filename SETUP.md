# GCP Terraform DNS Lab Setup Guide

This guide will walk you through setting up and deploying the GCP Terraform DNS Lab.

## Prerequisites

### 1. GCP Account and Project
- GCP account with billing enabled
- A GCP project (or create a new one)
- Project owner or editor permissions

### 2. Required Tools
- **Terraform** (>= 1.0): [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **Google Cloud SDK**: [Install gcloud](https://cloud.google.com/sdk/docs/install)
- **Git**: For cloning the repository

### 3. Optional Tools (Recommended)
- **tflint**: Terraform linter
- **checkov**: Security scanning
- **infracost**: Cost estimation

## Step-by-Step Setup

### Step 1: Authentication
```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project (replace with your project ID)
gcloud config set project YOUR_PROJECT_ID

# Create application default credentials
gcloud auth application-default login
```

### Step 2: Enable Required APIs
```bash
# Enable required GCP APIs
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudasset.googleapis.com

# Set your project
gcloud config set project strange-passage-483616-i1
```

### Step 3: Clone and Configure
```bash
# Clone the repository
git clone <repository-url>
cd gcp-terraform-dns-lab

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration file
nano terraform.tfvars  # or use your preferred editor
```

### Step 4: Update Configuration
Edit `terraform.tfvars` with your details:

```hcl
# Required: Update with your GCP project ID
project_id = "strange-passage-483616-i1"

# Optional: Customize other settings
region     = "us-central1"
zone       = "us-central1-a"

# Update DNS domains with your actual domain
public_dns_name = "learningmyway.space."
private_dns_name = "internal.learningmyway.space."
```

### Step 5: Initialize and Deploy
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Create execution plan
terraform plan

# Apply the configuration (creates resources)
terraform apply
```

Or use the Makefile:
```bash
# Quick setup
make setup

# Plan deployment
make plan

# Deploy infrastructure
make apply
```

## Environment-Specific Deployment

### Development Environment
```bash
make dev-plan    # Plan for dev
make dev         # Deploy to dev
```

### Production Environment
```bash
make prod-plan   # Plan for prod
make prod        # Deploy to prod
```

## Verification Steps

### 1. Check Terraform Outputs
```bash
terraform output
# or
make output
```

### 2. Verify VPC Creation
```bash
gcloud compute networks list
gcloud compute networks subnets list
```

### 3. Check DNS Zones
```bash
gcloud dns managed-zones list
gcloud dns record-sets list --zone=private-zone
gcloud dns record-sets list --zone=public-zone
```

### 4. Verify Load Balancer
```bash
gcloud compute forwarding-rules list
gcloud compute backend-services list
```

### 5. Test Load Balancer Access
```bash
# Get the load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)

# Test HTTP access
curl http://$LB_IP

# Test with custom headers
curl -H "Host: www.example.com" http://$LB_IP
```

### 6. Check Cloud Armor WAF
```bash
gcloud compute security-policies list
gcloud compute security-policies describe waf-security-policy
```

## Testing the Lab

### DNS Testing
```bash
# Create a test VM to test private DNS
gcloud compute instances create test-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --subnet=subnet-web \
  --no-address \
  --image-family=debian-11 \
  --image-project=debian-cloud

# SSH to the VM and test DNS
gcloud compute ssh test-vm --zone=us-central1-a

# Inside the VM, test private DNS resolution
nslookup web.internal.example.com
nslookup app.internal.example.com
```

### Load Balancer Testing
```bash
# Basic connectivity test
curl -v http://$(terraform output -raw load_balancer_ip)

# Test rate limiting (should get blocked after 100 requests)
for i in {1..150}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://$(terraform output -raw load_balancer_ip)
done

# Test WAF blocking (should return 403)
curl "http://$(terraform output -raw load_balancer_ip)/?test=<script>alert('xss')</script>"
```

### Firewall Testing
```bash
# Test SSH access (should work from Cloud Shell)
gcloud compute ssh test-vm --zone=us-central1-a

# Test internal connectivity between subnets
# (create VMs in different subnets and test ping)
```

## Monitoring and Logs

### View Logs
```bash
# VPC Flow Logs
gcloud logging read "resource.type=gce_subnetwork"

# Firewall Logs
gcloud logging read "resource.type=gce_firewall_rule"

# Load Balancer Logs
gcloud logging read "resource.type=http_load_balancer"

# Cloud Armor Logs
gcloud logging read "resource.type=gce_security_policy"
```

### Monitoring Dashboard
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to Monitoring > Dashboards
3. Create custom dashboards for your resources

## Troubleshooting

### Common Issues

1. **API Not Enabled**
   ```bash
   # Enable missing APIs
   gcloud services enable <api-name>
   ```

2. **Insufficient Permissions**
   ```bash
   # Check your permissions
   gcloud projects get-iam-policy YOUR_PROJECT_ID
   ```

3. **Quota Exceeded**
   ```bash
   # Check quotas
   gcloud compute project-info describe --project=YOUR_PROJECT_ID
   ```

4. **DNS Propagation**
   - Wait 5-10 minutes for DNS changes to propagate
   - Use `dig` or `nslookup` to test resolution

5. **SSL Certificate Issues**
   - Managed SSL certificates can take 10-60 minutes to provision
   - Ensure domains point to the load balancer IP

### Useful Commands
```bash
# Check Terraform state
terraform state list
terraform state show <resource>

# Refresh state
terraform refresh

# Import existing resources
terraform import <resource_type>.<name> <resource_id>

# Debug Terraform
export TF_LOG=DEBUG
terraform apply
```

## Cleanup

### Destroy Resources
```bash
# Destroy all resources
terraform destroy

# Or using Makefile
make destroy

# Environment-specific cleanup
make dev-destroy
make prod-destroy
```

### Manual Cleanup (if needed)
```bash
# List and delete any remaining resources
gcloud compute instances list
gcloud compute forwarding-rules list
gcloud dns managed-zones list

# Delete specific resources
gcloud compute instances delete <instance-name> --zone=<zone>
gcloud dns managed-zones delete <zone-name>
```

## Cost Optimization

### Estimated Costs (per month)
- **Compute Engine instances**: ~$5-10
- **Load Balancer**: ~$18-25
- **Cloud DNS**: ~$0.50
- **Cloud Armor**: ~$1-5
- **VPC**: Free (within limits)

### Cost Reduction Tips
1. Use preemptible instances for non-production
2. Implement auto-scaling to reduce idle resources
3. Use committed use discounts for production
4. Monitor usage with billing alerts

## Next Steps

1. **Customize for Your Use Case**
   - Modify subnet CIDR ranges
   - Add additional DNS records
   - Customize WAF rules
   - Add monitoring and alerting

2. **Production Readiness**
   - Implement Terraform remote state
   - Add CI/CD pipeline
   - Set up monitoring and alerting
   - Implement backup strategies

3. **Advanced Features**
   - Add Cloud SQL databases
   - Implement GKE clusters
   - Add Cloud Functions
   - Integrate with Cloud Build

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Terraform and GCP documentation
3. Open an issue in the repository
4. Consult GCP support if needed