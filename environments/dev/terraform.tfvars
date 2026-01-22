# Development Environment Configuration

project_id = "strange-passage-483616-i1"
region     = "us-central1"
zone       = "us-central1-a"

# Network Configuration
network_name = "dev-shared-vpc-network"

# DNS Configuration
private_zone_name = "dev-private-zone"
private_dns_name  = "internal.dev.learningmyway.space."
public_zone_name  = "dev-public-zone"
public_dns_name   = "dev.learningmyway.space."

# Environment
environment = "dev"

# Labels
labels = {
  environment = "dev"
  project     = "dns-lab"
  managed-by  = "terraform"
  cost-center = "development"
}

# Development-specific subnets
subnets = [
  {
    name          = "dev-subnet-web"
    ip_cidr_range = "10.1.1.0/24"
    region        = "us-central1"
    description   = "Development web tier subnet"
  },
  {
    name          = "dev-subnet-app"
    ip_cidr_range = "10.1.2.0/24"
    region        = "us-central1"
    description   = "Development application tier subnet"
  }
]