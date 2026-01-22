# GCP Terraform DNS Lab

This Terraform project demonstrates a comprehensive GCP infrastructure setup including:

- **Shared VPC** with multiple subnets
- **DNS Management** (Private and Public DNS zones)
- **IAM** (Service accounts, custom roles, and permissions)
- **Firewall Rules** (Network security)
- **Global Load Balancer** (HTTP/HTTPS with SSL)
- **Cloud Armor WAF** (Web Application Firewall)

## Architecture Overview

The lab creates a multi-tier architecture with:

1. **Network Layer**: Shared VPC with web, app, and database subnets
2. **Compute Layer**: Multi-tier instances (web, app, database) with bastion host
3. **DNS Layer**: Private DNS for internal communication, Public DNS for external access
4. **Security Layer**: Firewall rules and Cloud Armor WAF policies
5. **Load Balancing**: Global HTTP(S) Load Balancer with SSL termination
6. **IAM**: Service accounts with least-privilege access

## Prerequisites

1. **GCP Project**: A GCP project with billing enabled
2. **APIs**: The following APIs will be enabled automatically:
   - Compute Engine API
   - Cloud DNS API
   - Cloud Resource Manager API
   - IAM API
   - Service Networking API
   - Cloud Asset API

3. **Terraform**: Version >= 1.0
4. **Authentication**: Configure GCP authentication using one of:
   - `gcloud auth application-default login`
   - Service account key file
   - Workload Identity (for CI/CD)

## 📚 Documentation

This project includes comprehensive documentation:

- **[PROFESSIONAL_ARCHITECTURE.md](PROFESSIONAL_ARCHITECTURE.md)** - Enterprise-grade architecture documentation
- **[ARCHITECTURE_GUIDE.md](ARCHITECTURE_GUIDE.md)** - Complete architecture overview and component details
- **[BEGINNER_GUIDE.md](BEGINNER_GUIDE.md)** - Easy-to-understand explanations with real-world analogies
- **[NETWORK_DIAGRAM.md](NETWORK_DIAGRAM.md)** - Professional network architecture and traffic flow diagrams
- **[SETUP.md](SETUP.md)** - Step-by-step deployment instructions
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive testing procedures and validation
- **[TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md)** - Common issues and solutions
- **[Makefile](Makefile)** - Automated deployment and management commands

## 🎯 Quick Start Paths

### **For Enterprise/Professional Use**
1. Review [PROFESSIONAL_ARCHITECTURE.md](PROFESSIONAL_ARCHITECTURE.md) for enterprise-grade documentation
2. Examine [NETWORK_DIAGRAM.md](NETWORK_DIAGRAM.md) for detailed network architecture
3. Follow [SETUP.md](SETUP.md) for production deployment
4. Implement [TESTING_GUIDE.md](TESTING_GUIDE.md) for validation

### **For Beginners**
1. Read [BEGINNER_GUIDE.md](BEGINNER_GUIDE.md) to understand the concepts
2. Review [ARCHITECTURE_GUIDE.md](ARCHITECTURE_GUIDE.md) for technical details
3. Follow [SETUP.md](SETUP.md) for deployment
4. Use [TESTING_GUIDE.md](TESTING_GUIDE.md) to validate your deployment

### **For Experienced Users**
1. Review [PROFESSIONAL_ARCHITECTURE.md](PROFESSIONAL_ARCHITECTURE.md) for technical specifications
2. Use `make setup` for quick initialization
3. Customize `terraform.tfvars` for your environment
4. Deploy with `make apply`

## Quick Start

### **Option 1: Using Makefile (Recommended)**
```bash
# Quick setup and deployment
make setup          # Initialize and configure
make plan           # Review what will be created
make apply          # Deploy the infrastructure
```

### **Option 2: Manual Terraform**

1. **Clone and Setup**:
   ```bash
   git clone <repository-url>
   cd gcp-terraform-dns-lab
   ```

2. **Configure Variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your project details
   ```

3. **Initialize and Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

Edit `terraform.tfvars`:

```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"
```

### Optional Customizations

- **Network CIDR ranges**: Modify subnet configurations
- **DNS domains**: Update DNS zone names and domains
- **Firewall rules**: Adjust source IP ranges for SSH access
- **Load balancer**: Configure SSL domains
- **WAF policies**: Customize security rules

## Module Structure

```
modules/
├── vpc/           # Shared VPC and subnets
├── dns/           # Private and public DNS zones
├── iam/           # Service accounts and roles
├── firewall/      # Network security rules
├── instances/     # Compute instances (web, app, db, bastion)
├── load-balancer/ # Global HTTP(S) Load Balancer
└── waf/           # Cloud Armor WAF policies
```

### Key Features

### Compute Infrastructure
- **Multi-tier Architecture**: Web, application, and database tiers
- **Bastion Host**: Secure SSH access to internal resources
- **Auto-scaling**: Managed instance groups with health checks
- **Service Discovery**: DNS-based internal service communication

### DNS Management
- **Private DNS Zone**: For internal service discovery
- **Public DNS Zone**: For external domain resolution
- **DNS Policies**: Custom forwarding and logging

### Security
- **Firewall Rules**: Layered network security
- **Cloud Armor**: WAF with rate limiting and geo-blocking
- **IAM**: Least-privilege service accounts

### Load Balancing
- **Global Load Balancer**: HTTP/HTTPS with SSL termination
- **Health Checks**: Automated instance health monitoring
- **CDN**: Cloud CDN integration for static content

### High Availability
- **Multi-zone deployment**: Instances across availability zones
- **Auto-healing**: Automatic instance replacement
- **Auto-scaling**: Managed instance groups

## Testing the Deployment

1. **Check DNS Resolution**:
   ```bash
   # Test private DNS (from a VM in the VPC)
   nslookup web.internal.example.com
   
   # Test public DNS
   nslookup www.example.com
   ```

2. **Test Load Balancer**:
   ```bash
   # Get the load balancer IP
   terraform output load_balancer_ip
   
   # Test HTTP access
   curl http://<load-balancer-ip>
   ```

3. **Verify WAF Protection**:
   ```bash
   # Test rate limiting
   for i in {1..150}; do curl http://<load-balancer-ip>; done
   
   # Test blocked patterns
   curl "http://<load-balancer-ip>/?test=<script>alert('xss')</script>"
   ```

## Monitoring and Logging

- **VPC Flow Logs**: Network traffic analysis
- **Firewall Logs**: Security event monitoring
- **Load Balancer Logs**: Access and performance metrics
- **Cloud Armor Logs**: WAF security events

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources created by this Terraform configuration.

## Cost Optimization

- **Instance Types**: Uses e2-micro instances for cost efficiency
- **Preemptible Instances**: Consider using for non-production workloads
- **Resource Scheduling**: Implement start/stop schedules for development environments

## Security Best Practices

1. **Network Segmentation**: Separate subnets for different tiers
2. **Least Privilege**: Minimal IAM permissions
3. **Defense in Depth**: Multiple security layers
4. **Monitoring**: Comprehensive logging and alerting
5. **Regular Updates**: Keep Terraform and providers updated

## Troubleshooting

### Common Issues

1. **API Not Enabled**: Ensure all required APIs are enabled
2. **Quota Limits**: Check GCP quotas for your project
3. **Permissions**: Verify service account permissions
4. **DNS Propagation**: Allow time for DNS changes to propagate

### Useful Commands

```bash
# Check Terraform state
terraform state list

# View specific resource
terraform state show google_compute_network.vpc_network

# Import existing resources
terraform import google_compute_network.vpc_network projects/PROJECT_ID/global/networks/NETWORK_NAME
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.