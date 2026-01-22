#!/usr/bin/env python3
"""
GCP DNS Lab Professional Architecture Diagram Generator
Creates enterprise-grade visual representation of the infrastructure
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch, Rectangle, Circle
import numpy as np

# Set up the figure with professional styling
plt.style.use('default')
fig, ax = plt.subplots(1, 1, figsize=(24, 16))
ax.set_xlim(0, 24)
ax.set_ylim(0, 16)
ax.axis('off')
fig.patch.set_facecolor('white')

# Professional GCP color scheme
colors = {
    'gcp_blue': '#4285F4',
    'gcp_red': '#EA4335', 
    'gcp_yellow': '#FBBC04',
    'gcp_green': '#34A853',
    'internet': '#E8F0FE',
    'vpc': '#F8F9FA',
    'subnet_web': '#E3F2FD',
    'subnet_app': '#F3E5F5',
    'subnet_db': '#E8F5E8',
    'security': '#FFF3E0',
    'compute': '#FFFFFF',
    'text_primary': '#202124',
    'text_secondary': '#5F6368',
    'border': '#DADCE0'
}

# Title with professional styling
title_box = Rectangle((1, 14.5), 22, 1.2, facecolor=colors['gcp_blue'], alpha=0.1, edgecolor=colors['gcp_blue'])
ax.add_patch(title_box)
ax.text(12, 15.1, 'Google Cloud Platform - DNS Lab Architecture', 
        fontsize=20, fontweight='bold', ha='center', color=colors['gcp_blue'])
ax.text(12, 14.7, 'Multi-Tier Web Application with Comprehensive Security & DNS Management', 
        fontsize=12, ha='center', color=colors['text_secondary'])

# Internet/External Users zone
internet_zone = Rectangle((1, 12.5), 22, 1.5, 
                         facecolor=colors['internet'], 
                         edgecolor=colors['border'], linewidth=1.5)
ax.add_patch(internet_zone)
ax.text(2, 13.6, 'Internet / External Users', fontsize=14, fontweight='bold', color=colors['text_primary'])
ax.text(2, 13.2, 'Global Access Point', fontsize=10, color=colors['text_secondary'])

# External DNS representation
dns_external = Rectangle((18, 12.8), 4, 0.9, 
                        facecolor='white', edgecolor=colors['gcp_blue'], linewidth=1)
ax.add_patch(dns_external)
ax.text(20, 13.25, 'Public DNS', fontsize=10, fontweight='bold', ha='center')
ax.text(20, 13.05, 'example.com', fontsize=9, ha='center', color=colors['text_secondary'])

# Global Load Balancer with Cloud Armor
glb_box = Rectangle((8, 10.5), 8, 1.5, 
                   facecolor=colors['security'], 
                   edgecolor=colors['gcp_red'], linewidth=2)
ax.add_patch(glb_box)
ax.text(12, 11.6, 'Global HTTP(S) Load Balancer', fontsize=12, fontweight='bold', ha='center')
ax.text(12, 11.3, 'Cloud Armor WAF • SSL Termination • CDN', fontsize=10, ha='center', color=colors['text_secondary'])
ax.text(12, 11.0, 'IP: 34.102.136.180', fontsize=9, ha='center', color=colors['text_secondary'])

# GCP Project boundary
project_box = Rectangle((0.5, 0.5), 23, 9.5, 
                       facecolor='white', 
                       edgecolor=colors['gcp_blue'], linewidth=3)
ax.add_patch(project_box)
ax.text(1, 9.7, 'Google Cloud Project', fontsize=16, fontweight='bold', color=colors['gcp_blue'])
ax.text(1, 9.3, 'Project ID: your-gcp-project-id', fontsize=10, color=colors['text_secondary'])

# VPC Network
vpc_box = Rectangle((1, 1), 22, 8, 
                   facecolor=colors['vpc'], 
                   edgecolor=colors['gcp_green'], linewidth=2)
ax.add_patch(vpc_box)
ax.text(1.5, 8.7, 'Shared VPC Network', fontsize=14, fontweight='bold', color=colors['gcp_green'])
ax.text(1.5, 8.4, 'CIDR: 10.0.0.0/8 • Region: us-central1', fontsize=10, color=colors['text_secondary'])

# Cloud NAT and Router
nat_box = Rectangle((19, 7.5), 3.5, 1, 
                   facecolor='white', edgecolor=colors['gcp_blue'], linewidth=1)
ax.add_patch(nat_box)
ax.text(20.75, 8.1, 'Cloud NAT', fontsize=10, fontweight='bold', ha='center')
ax.text(20.75, 7.8, 'Outbound Internet', fontsize=8, ha='center', color=colors['text_secondary'])

# Subnets with proper enterprise styling
# Web Subnet
web_subnet = Rectangle((2, 5.5), 6, 2.5, 
                      facecolor=colors['subnet_web'], 
                      edgecolor=colors['gcp_blue'], linewidth=1.5)
ax.add_patch(web_subnet)
ax.text(5, 7.7, 'Web Tier Subnet', fontsize=12, fontweight='bold', ha='center')
ax.text(5, 7.4, '10.0.1.0/24 • us-central1-a,b,c', fontsize=9, ha='center', color=colors['text_secondary'])

# App Subnet
app_subnet = Rectangle((9, 5.5), 6, 2.5, 
                      facecolor=colors['subnet_app'], 
                      edgecolor=colors['gcp_blue'], linewidth=1.5)
ax.add_patch(app_subnet)
ax.text(12, 7.7, 'Application Tier Subnet', fontsize=12, fontweight='bold', ha='center')
ax.text(12, 7.4, '10.0.2.0/24 • us-central1-a,b,c', fontsize=9, ha='center', color=colors['text_secondary'])

# Database Subnet
db_subnet = Rectangle((16, 5.5), 6, 2.5, 
                     facecolor=colors['subnet_db'], 
                     edgecolor=colors['gcp_blue'], linewidth=1.5)
ax.add_patch(db_subnet)
ax.text(19, 7.7, 'Database Tier Subnet', fontsize=12, fontweight='bold', ha='center')
ax.text(19, 7.4, '10.0.3.0/24 • us-central1-a', fontsize=9, ha='center', color=colors['text_secondary'])

# Compute Instances with professional styling
# Web Instances
web1 = Rectangle((2.5, 6.2), 2.2, 0.8, 
                facecolor=colors['compute'], 
                edgecolor=colors['gcp_red'], linewidth=1.5)
ax.add_patch(web1)
ax.text(3.6, 6.7, 'web-1', fontsize=10, fontweight='bold', ha='center')
ax.text(3.6, 6.5, 'Nginx', fontsize=8, ha='center', color=colors['text_secondary'])
ax.text(3.6, 6.3, '10.0.1.10', fontsize=8, ha='center', color=colors['text_secondary'])

web2 = Rectangle((5.3, 6.2), 2.2, 0.8, 
                facecolor=colors['compute'], 
                edgecolor=colors['gcp_red'], linewidth=1.5)
ax.add_patch(web2)
ax.text(6.4, 6.7, 'web-2', fontsize=10, fontweight='bold', ha='center')
ax.text(6.4, 6.5, 'Nginx', fontsize=8, ha='center', color=colors['text_secondary'])
ax.text(6.4, 6.3, '10.0.1.11', fontsize=8, ha='center', color=colors['text_secondary'])

# App Instances
app1 = Rectangle((9.5, 6.2), 2.2, 0.8, 
                facecolor=colors['compute'], 
                edgecolor=colors['gcp_red'], linewidth=1.5)
ax.add_patch(app1)
ax.text(10.6, 6.7, 'app-1', fontsize=10, fontweight='bold', ha='center')
ax.text(10.6, 6.5, 'Node.js', fontsize=8, ha='center', color=colors['text_secondary'])
ax.text(10.6, 6.3, '10.0.2.10', fontsize=8, ha='center', color=colors['text_secondary'])

app2 = Rectangle((12.3, 6.2), 2.2, 0.8, 
                facecolor=colors['compute'], 
                edgecolor=colors['gcp_red'], linewidth=1.5)
ax.add_patch(app2)
ax.text(13.4, 6.7, 'app-2', fontsize=10, fontweight='bold', ha='center')
ax.text(13.4, 6.5, 'Node.js', fontsize=8, ha='center', color=colors['text_secondary'])
ax.text(13.4, 6.3, '10.0.2.11', fontsize=8, ha='center', color=colors['text_secondary'])

# Database Instance
db1 = Rectangle((17, 6.2), 3.5, 0.8, 
               facecolor=colors['compute'], 
               edgecolor=colors['gcp_red'], linewidth=1.5)
ax.add_patch(db1)
ax.text(18.75, 6.7, 'db-1', fontsize=10, fontweight='bold', ha='center')
ax.text(18.75, 6.5, 'PostgreSQL 14', fontsize=8, ha='center', color=colors['text_secondary'])
ax.text(18.75, 6.3, '10.0.3.10', fontsize=8, ha='center', color=colors['text_secondary'])

# Bastion Host
bastion = Rectangle((2.5, 5.7), 2.2, 0.4, 
                   facecolor=colors['security'], 
                   edgecolor=colors['gcp_yellow'], linewidth=1.5)
ax.add_patch(bastion)
ax.text(3.6, 5.9, 'bastion', fontsize=9, fontweight='bold', ha='center')
ax.text(3.6, 5.8, 'SSH Gateway', fontsize=7, ha='center', color=colors['text_secondary'])

# DNS Services
dns_box = Rectangle((2, 3.5), 20, 1.5, 
                   facecolor='white', 
                   edgecolor=colors['gcp_blue'], linewidth=1.5)
ax.add_patch(dns_box)
ax.text(12, 4.7, 'Google Cloud DNS Services', fontsize=14, fontweight='bold', ha='center', color=colors['gcp_blue'])

# Private DNS Zone
private_dns = Rectangle((3, 3.8), 8, 0.9, 
                       facecolor=colors['subnet_web'], 
                       edgecolor=colors['gcp_blue'], linewidth=1)
ax.add_patch(private_dns)
ax.text(7, 4.4, 'Private DNS Zone', fontsize=11, fontweight='bold', ha='center')
ax.text(7, 4.2, 'internal.example.com', fontsize=9, ha='center', color=colors['text_secondary'])
ax.text(7, 4.0, 'VPC-scoped resolution', fontsize=8, ha='center', color=colors['text_secondary'])

# Public DNS Zone
public_dns = Rectangle((13, 3.8), 8, 0.9, 
                      facecolor=colors['subnet_app'], 
                      edgecolor=colors['gcp_blue'], linewidth=1)
ax.add_patch(public_dns)
ax.text(17, 4.4, 'Public DNS Zone', fontsize=11, fontweight='bold', ha='center')
ax.text(17, 4.2, 'example.com', fontsize=9, ha='center', color=colors['text_secondary'])
ax.text(17, 4.0, 'Internet-wide resolution', fontsize=8, ha='center', color=colors['text_secondary'])

# Security and Management Services
security_box = Rectangle((2, 2), 20, 1.2, 
                        facecolor=colors['security'], 
                        edgecolor=colors['gcp_yellow'], linewidth=1.5)
ax.add_patch(security_box)
ax.text(12, 2.9, 'Security & Management Layer', fontsize=14, fontweight='bold', ha='center', color=colors['text_primary'])

# Individual security components
firewall = Rectangle((3, 2.2), 4, 0.6, 
                    facecolor='white', edgecolor=colors['gcp_red'], linewidth=1)
ax.add_patch(firewall)
ax.text(5, 2.5, 'VPC Firewall Rules', fontsize=9, fontweight='bold', ha='center')

iam = Rectangle((8, 2.2), 4, 0.6, 
               facecolor='white', edgecolor=colors['gcp_red'], linewidth=1)
ax.add_patch(iam)
ax.text(10, 2.5, 'IAM & Service Accounts', fontsize=9, fontweight='bold', ha='center')

monitoring = Rectangle((13, 2.2), 4, 0.6, 
                      facecolor='white', edgecolor=colors['gcp_red'], linewidth=1)
ax.add_patch(monitoring)
ax.text(15, 2.5, 'Cloud Ops Suite', fontsize=9, fontweight='bold', ha='center')

storage = Rectangle((18, 2.2), 3, 0.6, 
                   facecolor='white', edgecolor=colors['gcp_red'], linewidth=1)
ax.add_patch(storage)
ax.text(19.5, 2.5, 'Persistent Disks', fontsize=9, fontweight='bold', ha='center')

# Professional connection arrows
# Internet to Load Balancer
arrow1 = ConnectionPatch((12, 12.5), (12, 12), "data", "data",
                        arrowstyle="->", shrinkA=0, shrinkB=0, 
                        mutation_scale=25, fc=colors['gcp_blue'], ec=colors['gcp_blue'], linewidth=2)
ax.add_artist(arrow1)

# Load Balancer to Web Tier
arrow2 = ConnectionPatch((12, 10.5), (5, 8), "data", "data",
                        arrowstyle="->", shrinkA=0, shrinkB=0, 
                        mutation_scale=25, fc=colors['gcp_red'], ec=colors['gcp_red'], linewidth=2)
ax.add_artist(arrow2)

# Web to App Tier
arrow3 = ConnectionPatch((8, 6.6), (9.5, 6.6), "data", "data",
                        arrowstyle="->", shrinkA=0, shrinkB=0, 
                        mutation_scale=20, fc=colors['gcp_green'], ec=colors['gcp_green'], linewidth=1.5)
ax.add_artist(arrow3)

# App to Database Tier
arrow4 = ConnectionPatch((14.5, 6.6), (17, 6.6), "data", "data",
                        arrowstyle="->", shrinkA=0, shrinkB=0, 
                        mutation_scale=20, fc=colors['gcp_green'], ec=colors['gcp_green'], linewidth=1.5)
ax.add_artist(arrow4)

# Professional legend
legend_box = Rectangle((0.5, 0.2), 23, 0.6, 
                      facecolor='white', edgecolor=colors['border'], linewidth=1)
ax.add_patch(legend_box)

legend_items = [
    (2, 0.5, colors['gcp_blue'], 'Network Infrastructure'),
    (6, 0.5, colors['gcp_red'], 'Compute Resources'),
    (10, 0.5, colors['gcp_green'], 'Data Flow'),
    (14, 0.5, colors['gcp_yellow'], 'Security Layer'),
    (18, 0.5, colors['security'], 'Management Services')
]

for x, y, color, label in legend_items:
    legend_rect = Rectangle((x-0.2, y-0.1), 0.3, 0.2, facecolor=color, alpha=0.7)
    ax.add_patch(legend_rect)
    ax.text(x+0.3, y, label, fontsize=9, va='center', color=colors['text_primary'])

# Add zone indicators
ax.text(23, 7, 'Zone: us-central1-a', fontsize=8, ha='right', color=colors['text_secondary'], rotation=90)
ax.text(23, 5, 'Zone: us-central1-b', fontsize=8, ha='right', color=colors['text_secondary'], rotation=90)
ax.text(23, 3, 'Zone: us-central1-c', fontsize=8, ha='right', color=colors['text_secondary'], rotation=90)

plt.tight_layout()
plt.savefig('gcp-dns-lab-architecture-professional.png', dpi=300, bbox_inches='tight', 
            facecolor='white', edgecolor='none', pad_inches=0.2)
plt.savefig('gcp-dns-lab-architecture-professional.pdf', bbox_inches='tight', 
            facecolor='white', edgecolor='none', pad_inches=0.2)

plt.tight_layout()
plt.savefig('gcp-dns-lab-architecture.png', dpi=300, bbox_inches='tight', 
            facecolor='white', edgecolor='none')
plt.savefig('gcp-dns-lab-architecture.pdf', bbox_inches='tight', 
            facecolor='white', edgecolor='none')

print("Professional architecture diagram saved as:")
print("- gcp-dns-lab-architecture-professional.png")
print("- gcp-dns-lab-architecture-professional.pdf")

# Create a professional network flow diagram
fig2, ax2 = plt.subplots(1, 1, figsize=(20, 12))
ax2.set_xlim(0, 20)
ax2.set_ylim(0, 12)
ax2.axis('off')
fig2.patch.set_facecolor('white')

# Title
title_box = Rectangle((1, 10.5), 18, 1.2, facecolor=colors['gcp_blue'], alpha=0.1, edgecolor=colors['gcp_blue'])
ax2.add_patch(title_box)
ax2.text(10, 11.1, 'GCP DNS Lab - Professional Network Flow Architecture', 
         fontsize=18, fontweight='bold', ha='center', color=colors['gcp_blue'])
ax2.text(10, 10.7, 'Request Processing & Data Flow Patterns', 
         fontsize=12, ha='center', color=colors['text_secondary'])

# Create professional flow steps with proper enterprise styling
flow_steps = [
    (3, 8.5, "External User\nRequest", "HTTPS Request\nwww.example.com", colors['internet']),
    (10, 8.5, "Global Load Balancer\n& Cloud Armor", "SSL Termination\nWAF Security Check\nHealth Check", colors['security']),
    (17, 8.5, "Web Tier\nNginx Servers", "Static Content\nReverse Proxy\nLoad Distribution", colors['subnet_web']),
    (17, 6, "Application Tier\nNode.js Servers", "Business Logic\nAPI Processing\nSession Management", colors['subnet_app']),
    (17, 3.5, "Database Tier\nPostgreSQL", "Data Storage\nQuery Processing\nTransaction Management", colors['subnet_db']),
    (10, 2, "DNS Resolution\nServices", "Private Zone\nPublic Zone\nService Discovery", colors['gcp_blue']),
    (3, 2, "Response\nDelivery", "JSON/HTML Response\nCaching Headers\nCompression", colors['internet'])
]

for i, (x, y, title, details, color) in enumerate(flow_steps):
    # Main step box
    step_box = Rectangle((x-1.2, y-0.8), 2.4, 1.6, 
                        facecolor=color, alpha=0.2, edgecolor=color, linewidth=2)
    ax2.add_patch(step_box)
    
    # Step number
    step_circle = Circle((x-0.8, y+0.5), 0.2, facecolor=colors['gcp_blue'], edgecolor='white', linewidth=2)
    ax2.add_patch(step_circle)
    ax2.text(x-0.8, y+0.5, str(i+1), fontsize=10, fontweight='bold', ha='center', va='center', color='white')
    
    # Step title
    ax2.text(x, y+0.3, title, fontsize=11, fontweight='bold', ha='center', color=colors['text_primary'])
    
    # Step details
    ax2.text(x, y-0.3, details, fontsize=9, ha='center', color=colors['text_secondary'])

# Professional flow arrows with labels
flow_connections = [
    ((4.2, 8.5), (8.8, 8.5), "DNS Resolution\n& Routing"),
    ((11.2, 8.5), (15.8, 8.5), "Load Balanced\nHTTP Request"),
    ((17, 7.7), (17, 6.8), "API Call\nProxy"),
    ((17, 5.2), (17, 4.3), "Database\nQuery"),
    ((15.8, 3.5), (11.2, 2.5), "Service\nDiscovery"),
    ((8.8, 2), (4.2, 2), "Formatted\nResponse"),
    ((3, 2.8), (3, 7.7), "Complete\nRound Trip")
]

for i, (start, end, label) in enumerate(flow_connections):
    if i < 6:  # Forward flow
        arrow_color = colors['gcp_green']
        arrow_style = "->"
    else:  # Return flow
        arrow_color = colors['gcp_red']
        arrow_style = "<-"
    
    arrow = ConnectionPatch(start, end, "data", "data",
                           arrowstyle=arrow_style, shrinkA=5, shrinkB=5, 
                           mutation_scale=20, fc=arrow_color, ec=arrow_color, linewidth=2)
    ax2.add_artist(arrow)
    
    # Add flow labels
    mid_x = (start[0] + end[0]) / 2
    mid_y = (start[1] + end[1]) / 2
    if start[1] == end[1]:  # Horizontal arrow
        label_y = mid_y + 0.4
    else:  # Vertical arrow
        label_y = mid_y
        mid_x += 0.8 if i == 6 else -0.8
    
    ax2.text(mid_x, label_y, label, fontsize=8, ha='center', 
             bbox=dict(boxstyle="round,pad=0.2", facecolor='white', alpha=0.8, edgecolor=arrow_color))

# Add timing and performance indicators
performance_box = Rectangle((1, 0.2), 18, 1, 
                           facecolor=colors['gcp_yellow'], alpha=0.1, edgecolor=colors['gcp_yellow'])
ax2.add_patch(performance_box)
ax2.text(10, 0.9, 'Performance Metrics & SLA Targets', fontsize=12, fontweight='bold', ha='center')
ax2.text(4, 0.5, 'DNS Resolution: <50ms', fontsize=9, ha='center', color=colors['text_secondary'])
ax2.text(8, 0.5, 'Load Balancer: <100ms', fontsize=9, ha='center', color=colors['text_secondary'])
ax2.text(12, 0.5, 'Application: <200ms', fontsize=9, ha='center', color=colors['text_secondary'])
ax2.text(16, 0.5, 'Database Query: <50ms', fontsize=9, ha='center', color=colors['text_secondary'])

plt.tight_layout()
plt.savefig('gcp-dns-lab-flow-professional.png', dpi=300, bbox_inches='tight', 
            facecolor='white', edgecolor='none', pad_inches=0.2)

print("- gcp-dns-lab-flow-professional.png")
print("\nProfessional diagrams generated successfully!")