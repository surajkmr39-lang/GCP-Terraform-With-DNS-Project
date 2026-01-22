# 🏗️ GCP DNS Lab - Complete Architecture Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Architecture Components](#architecture-components)
3. [Network Flow](#network-flow)
4. [Security Layers](#security-layers)
5. [DNS Resolution](#dns-resolution)
6. [Component Details](#component-details)
7. [Data Flow Examples](#data-flow-examples)

---

## 🎯 Overview

This GCP DNS Lab creates a **production-ready, multi-tier web application** with comprehensive security, monitoring, and DNS management. Think of it as a complete "digital city" with different neighborhoods (subnets), security checkpoints (firewalls), and a phone book system (DNS).

### 🏢 What We're Building
- **A 3-tier web application** (Web → App → Database)
- **Complete DNS management** (both internal and external)
- **Enterprise-grade security** (firewalls, WAF, IAM)
- **High availability** (load balancing, health checks)
- **Monitoring and logging** (comprehensive observability)

---

## 🧩 Architecture Components

### 🌐 **1. Internet Layer**
```
Internet Users → Global Load Balancer
```
- **What it is**: The entry point for all external traffic
- **Why it matters**: Provides global access to your application
- **Real-world analogy**: Like the main entrance to a shopping mall

### ⚖️ **2. Load Balancer + WAF**
```
Global HTTP(S) Load Balancer + Cloud Armor WAF
```
- **What it does**: 
  - Distributes traffic across multiple web servers
  - Blocks malicious requests (DDoS, SQL injection, etc.)
  - Handles SSL termination
- **Why it's important**: Ensures high availability and security
- **Real-world analogy**: Like a security guard + traffic director at the mall entrance

### 🏠 **3. VPC Network (The Foundation)**
```
Shared VPC: 10.0.0.0/8
├── Web Subnet: 10.0.1.0/24
├── App Subnet: 10.0.2.0/24
└── DB Subnet: 10.0.3.0/24
```
- **What it is**: Your private network in the cloud
- **Why subnets**: Separates different tiers for security and organization
- **Real-world analogy**: Like different floors in an office building

### 💻 **4. Compute Instances (The Workers)**

#### **Web Tier (Frontend)**
- **2x Nginx Web Servers**
- **Purpose**: Serve web pages and proxy API requests
- **Location**: Web Subnet (10.0.1.0/24)
- **Access**: Public via Load Balancer

#### **App Tier (Backend)**
- **2x Node.js Application Servers**
- **Purpose**: Handle business logic and API requests
- **Location**: App Subnet (10.0.2.0/24)
- **Access**: Internal only (from Web tier)

#### **Database Tier (Storage)**
- **1x PostgreSQL Database Server**
- **Purpose**: Store and manage application data
- **Location**: DB Subnet (10.0.3.0/24)
- **Access**: Internal only (from App tier)

#### **Bastion Host (Management)**
- **1x Hardened SSH Gateway**
- **Purpose**: Secure access to internal resources
- **Location**: Web Subnet (has external IP)
- **Access**: SSH from authorized IPs only

### 🔍 **5. DNS System (The Phone Book)**

#### **Private DNS Zone**
```
internal.example.com
├── web-1.internal.example.com → 10.0.1.10
├── web-2.internal.example.com → 10.0.1.11
├── app-1.internal.example.com → 10.0.2.10
├── app-2.internal.example.com → 10.0.2.11
└── db-1.internal.example.com → 10.0.3.10
```
- **Purpose**: Internal service discovery
- **Visibility**: Only within the VPC
- **Use case**: Services finding each other

#### **Public DNS Zone**
```
example.com
├── www.example.com → Load Balancer IP
├── api.example.com → Load Balancer IP
└── mail.example.com → Mail Server IP
```
- **Purpose**: External domain resolution
- **Visibility**: Internet-wide
- **Use case**: Users accessing your website

---

## 🌊 Network Flow

### **Step-by-Step Request Flow**

```
1. User types "www.example.com" in browser
   ↓
2. DNS resolves to Load Balancer IP
   ↓
3. Load Balancer receives HTTPS request
   ↓
4. WAF checks request for security threats
   ↓
5. Load Balancer forwards to Web Server
   ↓
6. Web Server processes request
   ↓
7. If API needed: Web → App Server
   ↓
8. If data needed: App → Database
   ↓
9. Response flows back: DB → App → Web → LB → User
```

### **Internal Communication Example**
```
Web Server needs to call API:
web-1.internal.example.com → app-1.internal.example.com
(10.0.1.10) → (10.0.2.10)
```

---

## 🔒 Security Layers

### **1. Network Security**
- **Firewall Rules**: Control traffic between subnets
- **No External IPs**: Internal servers can't be accessed directly
- **Cloud NAT**: Allows outbound internet access without exposure

### **2. Application Security**
- **Cloud Armor WAF**: Blocks malicious requests
- **Rate Limiting**: Prevents abuse
- **Geo-blocking**: Blocks traffic from specific countries

### **3. Access Security**
- **IAM Service Accounts**: Each service has minimal required permissions
- **SSH Key Authentication**: No password-based access
- **Bastion Host**: Single point of secure access

### **4. Data Security**
- **Private Subnets**: Database not accessible from internet
- **Encrypted Storage**: All data encrypted at rest
- **VPC Flow Logs**: Monitor all network traffic

---

## 🔍 DNS Resolution

### **How DNS Works in This Lab**

#### **External User Accessing Website**
```
1. User → "www.example.com"
2. Public DNS → Returns Load Balancer IP
3. User connects to Load Balancer
```

#### **Internal Service Communication**
```
1. Web Server → "app-1.internal.example.com"
2. Private DNS → Returns 10.0.2.10
3. Web Server connects to App Server
```

#### **DNS Policies**
- **Forwarding**: External DNS queries go to 8.8.8.8
- **Logging**: All DNS queries are logged
- **Caching**: Responses cached for performance

---

## 🔧 Component Details

### **Web Servers (Nginx)**
```bash
# What they do:
- Serve static content (HTML, CSS, JS)
- Proxy API requests to App servers
- Handle SSL termination (via Load Balancer)
- Health check endpoints

# Configuration:
- Port 80 (HTTP)
- Reverse proxy to app-1.internal.example.com
- Custom error pages
- Gzip compression
```

### **App Servers (Node.js)**
```bash
# What they do:
- REST API endpoints
- Business logic processing
- Database connections
- Session management

# Endpoints:
- GET /api/users
- GET /api/health
- GET /api/metrics
- POST /api/data
```

### **Database Server (PostgreSQL)**
```bash
# What it stores:
- User data
- Application logs
- System metrics
- Session information

# Features:
- Automated backups
- Performance monitoring
- Connection pooling
- Query logging
```

### **Bastion Host**
```bash
# Security features:
- SSH key-only authentication
- Fail2ban (blocks brute force)
- UFW firewall
- Session logging
- Automatic security updates

# Management tools:
- gcloud CLI
- DNS testing utilities
- System monitoring scripts
```

---

## 📊 Data Flow Examples

### **Example 1: User Loads Website**
```
1. User → https://www.example.com
2. DNS → Returns 34.102.136.180 (Load Balancer)
3. Load Balancer → Checks WAF rules
4. WAF → Allows request (not malicious)
5. Load Balancer → Forwards to web-1 (10.0.1.10)
6. Web Server → Returns HTML page
7. Response → Flows back to user
```

### **Example 2: API Call for User Data**
```
1. Frontend → GET /api/users
2. Web Server → Proxies to app-1.internal.example.com
3. App Server → Queries database at db-1.internal.example.com
4. Database → Returns user data
5. App Server → Formats JSON response
6. Web Server → Returns to frontend
7. User → Sees user list
```

### **Example 3: Admin SSH Access**
```
1. Admin → SSH to bastion host (external IP)
2. Bastion → Authenticates with SSH key
3. Admin → gcloud compute ssh web-1 --zone=us-central1-a
4. Connection → Tunneled through bastion to web server
5. Admin → Can manage internal servers securely
```

---

## 🎯 Key Benefits

### **High Availability**
- Multiple instances in different zones
- Health checks and auto-healing
- Load balancing across instances

### **Security**
- Multiple layers of protection
- Principle of least privilege
- Comprehensive logging

### **Scalability**
- Easy to add more instances
- Auto-scaling capabilities
- CDN for static content

### **Maintainability**
- Infrastructure as Code (Terraform)
- Automated deployments
- Comprehensive monitoring

---

## 🚀 Getting Started

1. **Review the architecture diagrams** (generated PNG files)
2. **Read the SETUP.md** for deployment instructions
3. **Customize variables** in terraform.tfvars
4. **Deploy with Terraform** using the Makefile
5. **Test the deployment** using provided scripts

---

## 📚 Next Steps

After understanding this architecture:
1. **Deploy the lab** following SETUP.md
2. **Explore the components** via bastion host
3. **Test DNS resolution** with provided tools
4. **Monitor traffic** through GCP console
5. **Customize for your needs** by modifying Terraform code

This architecture provides a solid foundation for understanding enterprise cloud infrastructure and can be adapted for real-world applications.