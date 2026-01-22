# Production Environment Configuration

project_id = "strange-passage-483616-i1"
region     = "us-central1"
zone       = "us-central1-a"

# Network Configuration
network_name = "prod-shared-vpc-network"

# DNS Configuration
private_zone_name = "prod-private-zone"
private_dns_name  = "internal.learningmyway.space."
public_zone_name  = "prod-public-zone"
public_dns_name   = "learningmyway.space."

# Environment
environment = "prod"

# Labels
labels = {
  environment = "prod"
  project     = "dns-lab"
  managed-by  = "terraform"
  cost-center = "production"
}

# Production-specific subnets with larger CIDR blocks
subnets = [
  {
    name          = "prod-subnet-web"
    ip_cidr_range = "10.0.1.0/24"
    region        = "us-central1"
    description   = "Production web tier subnet"
  },
  {
    name          = "prod-subnet-app"
    ip_cidr_range = "10.0.2.0/24"
    region        = "us-central1"
    description   = "Production application tier subnet"
  },
  {
    name          = "prod-subnet-db"
    ip_cidr_range = "10.0.3.0/24"
    region        = "us-central1"
    description   = "Production database tier subnet"
  }
]