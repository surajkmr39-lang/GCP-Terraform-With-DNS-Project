#!/bin/bash

# Application Server Startup Script
# This script configures an application server with Node.js and basic API

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
    lsb-release \
    build-essential

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install PM2 for process management
npm install -g pm2

# Install Google Cloud Ops Agent for monitoring and logging
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Create package.json
cat > package.json << 'EOF'
{
  "name": "dns-lab-app",
  "version": "1.0.0",
  "description": "GCP DNS Lab Application Server",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "compression": "^1.7.4"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Install dependencies
npm install

# Create main application server
cat > server.js << EOF
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const os = require('os');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Instance information
const instanceInfo = {
    name: '${INSTANCE_NAME}',
    hostname: os.hostname(),
    platform: os.platform(),
    arch: os.arch(),
    nodeVersion: process.version,
    uptime: process.uptime(),
    dnsZone: '${DNS_ZONE}',
    projectId: '${PROJECT_ID}'
};

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        instance: instanceInfo.name
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        status: 'running',
        service: 'app-server',
        instance: instanceInfo,
        timestamp: new Date().toISOString(),
        environment: {
            nodeVersion: process.version,
            platform: os.platform(),
            arch: os.arch(),
            cpus: os.cpus().length,
            totalMemory: os.totalmem(),
            freeMemory: os.freemem(),
            loadAverage: os.loadavg()
        }
    });
});

// API endpoints
app.get('/api/info', (req, res) => {
    res.json({
        message: 'GCP DNS Lab Application Server',
        instance: instanceInfo,
        timestamp: new Date().toISOString()
    });
});

// Database connection test
app.get('/api/db/test', async (req, res) => {
    try {
        // Simulate database connection test
        const dbHost = 'db-1.${DNS_ZONE}';
        const { exec } = require('child_process');
        
        exec(\`ping -c 1 \$\{dbHost\}\`, (error, stdout, stderr) => {
            if (error) {
                res.status(500).json({
                    status: 'error',
                    message: 'Database connection failed',
                    error: error.message,
                    dbHost: dbHost
                });
            } else {
                res.json({
                    status: 'success',
                    message: 'Database connection test passed',
                    dbHost: dbHost,
                    timestamp: new Date().toISOString()
                });
            }
        });
    } catch (error) {
        res.status(500).json({
            status: 'error',
            message: 'Database test failed',
            error: error.message
        });
    }
});

// Users API (mock data)
const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user' },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'user' }
];

app.get('/api/users', (req, res) => {
    res.json({
        status: 'success',
        data: users,
        count: users.length,
        instance: instanceInfo.name,
        timestamp: new Date().toISOString()
    });
});

app.get('/api/users/:id', (req, res) => {
    const userId = parseInt(req.params.id);
    const user = users.find(u => u.id === userId);
    
    if (user) {
        res.json({
            status: 'success',
            data: user,
            instance: instanceInfo.name,
            timestamp: new Date().toISOString()
        });
    } else {
        res.status(404).json({
            status: 'error',
            message: 'User not found',
            instance: instanceInfo.name,
            timestamp: new Date().toISOString()
        });
    }
});

// Metrics endpoint
app.get('/api/metrics', (req, res) => {
    res.json({
        status: 'success',
        metrics: {
            uptime: process.uptime(),
            memory: process.memoryUsage(),
            cpu: process.cpuUsage(),
            system: {
                loadAverage: os.loadavg(),
                totalMemory: os.totalmem(),
                freeMemory: os.freemem(),
                cpuCount: os.cpus().length
            }
        },
        instance: instanceInfo.name,
        timestamp: new Date().toISOString()
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        status: 'error',
        message: 'Internal server error',
        instance: instanceInfo.name,
        timestamp: new Date().toISOString()
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        status: 'error',
        message: 'Endpoint not found',
        path: req.path,
        instance: instanceInfo.name,
        timestamp: new Date().toISOString()
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log('Application server started on port ' + PORT);
    console.log('Instance: ' + instanceInfo.name);
    console.log('DNS Zone: ' + instanceInfo.dnsZone);
    console.log('Project: ' + instanceInfo.projectId);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully');
    process.exit(0);
});
EOF

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'dns-lab-app',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/log/app-error.log',
    out_file: '/var/log/app-out.log',
    log_file: '/var/log/app-combined.log',
    time: true,
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
EOF

# Set proper ownership
chown -R ubuntu:ubuntu /opt/app

# Start application with PM2
cd /opt/app
sudo -u ubuntu pm2 start ecosystem.config.js
sudo -u ubuntu pm2 save
sudo -u ubuntu pm2 startup

# Install Nginx as reverse proxy
apt-get install -y nginx

# Configure Nginx as reverse proxy
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    
    # Health check endpoint (direct)
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Proxy all other requests to Node.js app
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
EOF

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 3000/tcp
    ufw --force enable
fi

# Create monitoring script
cat > /usr/local/bin/app-monitor.sh << 'EOF'
#!/bin/bash
# Simple monitoring script for app server

LOG_FILE="/var/log/app-monitor.log"

echo "$(date): App server monitoring check" >> $LOG_FILE

# Check PM2 processes
PM2_STATUS=$(sudo -u ubuntu pm2 list | grep "dns-lab-app" | grep "online" | wc -l)
if [ $PM2_STATUS -eq 0 ]; then
    echo "$(date): ERROR - PM2 app is not running" >> $LOG_FILE
    sudo -u ubuntu pm2 restart dns-lab-app
else
    echo "$(date): PM2 app is running ($PM2_STATUS instances)" >> $LOG_FILE
fi

# Check Nginx status
if systemctl is-active --quiet nginx; then
    echo "$(date): Nginx is running" >> $LOG_FILE
else
    echo "$(date): ERROR - Nginx is not running" >> $LOG_FILE
    systemctl restart nginx
fi

# Check application health
HEALTH_CHECK=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost/health)
if [ "$HEALTH_CHECK" = "200" ]; then
    echo "$(date): Health check passed" >> $LOG_FILE
else
    echo "$(date): WARNING - Health check failed (HTTP $HEALTH_CHECK)" >> $LOG_FILE
fi
EOF

chmod +x /usr/local/bin/app-monitor.sh

# Add monitoring script to cron
echo "*/5 * * * * root /usr/local/bin/app-monitor.sh" >> /etc/crontab

# Log startup completion
echo "$(date): App server startup script completed successfully" >> /var/log/startup.log

# Signal that startup is complete
echo "App server startup completed on $INSTANCE_NAME" | logger