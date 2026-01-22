#!/bin/bash

# Web Server Startup Script
# This script configures a web server with Nginx and basic monitoring

set -e

# Variables from Terraform
INSTANCE_NAME="${instance_name}"
DNS_ZONE="${DNS_ZONE}"
PROJECT_ID="${PROJECT_ID}"

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y \
    nginx \
    curl \
    wget \
    htop \
    net-tools \
    dnsutils \
    jq \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Google Cloud Ops Agent for monitoring and logging
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Configure Nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name _;
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Main application
    location / {
        try_files $uri $uri/ =404;
    }
    
    # API proxy to app tier
    location /api/ {
        proxy_pass http://app-1.${DNS_ZONE}/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

# Create custom index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GCP DNS Lab - Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #4285f4; border-bottom: 2px solid #4285f4; padding-bottom: 10px; }
        .info-box { background: #e8f0fe; padding: 15px; margin: 15px 0; border-radius: 5px; }
        .status { color: #0f9d58; font-weight: bold; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🌐 GCP DNS Lab - Web Server</h1>
        
        <div class="info-box">
            <p class="status">✅ Server Status: Online</p>
            <p><strong>Instance:</strong> ${INSTANCE_NAME}</p>
            <p><strong>Hostname:</strong> <span id="hostname">Loading...</span></p>
            <p><strong>Zone:</strong> <span id="zone">Loading...</span></p>
            <p><strong>Internal IP:</strong> <span id="internal-ip">Loading...</span></p>
            <p><strong>Timestamp:</strong> <span id="timestamp">$(date)</span></p>
        </div>
        
        <h2>🔧 System Information</h2>
        <table>
            <tr><th>Property</th><th>Value</th></tr>
            <tr><td>OS</td><td><span id="os">$(lsb_release -d | cut -f2)</span></td></tr>
            <tr><td>Kernel</td><td><span id="kernel">$(uname -r)</span></td></tr>
            <tr><td>Uptime</td><td><span id="uptime">$(uptime -p)</span></td></tr>
            <tr><td>Load Average</td><td><span id="load">$(uptime | awk -F'load average:' '{print $2}')</span></td></tr>
        </table>
        
        <h2>🌍 DNS Configuration</h2>
        <div class="info-box">
            <p><strong>Private DNS Zone:</strong> ${DNS_ZONE}</p>
            <p><strong>DNS Servers:</strong> <span id="dns-servers">$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')</span></p>
        </div>
        
        <h2>🔗 Service Links</h2>
        <ul>
            <li><a href="/health">Health Check</a></li>
            <li><a href="/api/status">API Status</a> (proxied to app tier)</li>
            <li><a href="http://app-1.${DNS_ZONE}">App Server 1</a> (internal)</li>
            <li><a href="http://db-1.${DNS_ZONE}">Database Server 1</a> (internal)</li>
        </ul>
        
        <div class="footer">
            <p>🏗️ Infrastructure managed by Terraform | 🔒 Secured by Cloud Armor WAF</p>
            <p>Project: ${PROJECT_ID}</p>
        </div>
    </div>
    
    <script>
        // Fetch metadata from GCP metadata server
        function fetchMetadata() {
            const headers = {'Metadata-Flavor': 'Google'};
            
            fetch('http://metadata.google.internal/computeMetadata/v1/instance/hostname', {headers})
                .then(r => r.text()).then(data => document.getElementById('hostname').textContent = data)
                .catch(() => document.getElementById('hostname').textContent = 'N/A');
                
            fetch('http://metadata.google.internal/computeMetadata/v1/instance/zone', {headers})
                .then(r => r.text()).then(data => document.getElementById('zone').textContent = data.split('/').pop())
                .catch(() => document.getElementById('zone').textContent = 'N/A');
                
            fetch('http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip', {headers})
                .then(r => r.text()).then(data => document.getElementById('internal-ip').textContent = data)
                .catch(() => document.getElementById('internal-ip').textContent = 'N/A');
        }
        
        fetchMetadata();
        
        // Update timestamp every second
        setInterval(() => {
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
        }, 1000);
    </script>
</body>
</html>
EOF

# Create API status endpoint
mkdir -p /var/www/html/api
cat > /var/www/html/api/index.html << EOF
{
  "status": "healthy",
  "service": "web-server",
  "instance": "${INSTANCE_NAME}",
  "timestamp": "$(date -Iseconds)",
  "version": "1.0.0"
}
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
fi

# Create a simple monitoring script
cat > /usr/local/bin/web-monitor.sh << 'EOF'
#!/bin/bash
# Simple monitoring script for web server

LOG_FILE="/var/log/web-monitor.log"

echo "$(date): Web server monitoring check" >> $LOG_FILE

# Check Nginx status
if systemctl is-active --quiet nginx; then
    echo "$(date): Nginx is running" >> $LOG_FILE
else
    echo "$(date): ERROR - Nginx is not running" >> $LOG_FILE
    systemctl restart nginx
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "$(date): WARNING - Disk usage is $DISK_USAGE%" >> $LOG_FILE
fi

# Check memory usage
MEM_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
echo "$(date): Memory usage: $MEM_USAGE%" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/web-monitor.sh

# Add monitoring script to cron
echo "*/5 * * * * root /usr/local/bin/web-monitor.sh" >> /etc/crontab

# Log startup completion
echo "$(date): Web server startup script completed successfully" >> /var/log/startup.log

# Signal that startup is complete
systemctl restart nginx
echo "Web server startup completed on $INSTANCE_NAME" | logger