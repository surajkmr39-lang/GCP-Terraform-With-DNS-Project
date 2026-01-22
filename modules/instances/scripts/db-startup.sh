#!/bin/bash

# Database Server Startup Script
# This script configures a database server with PostgreSQL

set -e

# Variables from Terraform
INSTANCE_NAME="${instance_name}"
DNS_ZONE="${DNS_ZONE}"
PROJECT_ID="${PROJECT_ID}"

# Database configuration
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"
DB_PASSWORD="SecurePassword123!"

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
    lsb-release

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib postgresql-client

# Install Google Cloud Ops Agent for monitoring and logging
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Format and mount the additional data disk
DATA_DISK="/dev/disk/by-id/google-database-data"
MOUNT_POINT="/var/lib/postgresql-data"

if [ -b "$DATA_DISK" ]; then
    echo "Formatting and mounting data disk..."
    
    # Create filesystem if not exists
    if ! blkid "$DATA_DISK"; then
        mkfs.ext4 -F "$DATA_DISK"
    fi
    
    # Create mount point
    mkdir -p "$MOUNT_POINT"
    
    # Mount the disk
    mount "$DATA_DISK" "$MOUNT_POINT"
    
    # Add to fstab for persistent mounting
    echo "$DATA_DISK $MOUNT_POINT ext4 defaults 0 2" >> /etc/fstab
    
    # Set proper ownership
    chown -R postgres:postgres "$MOUNT_POINT"
    chmod 700 "$MOUNT_POINT"
    
    echo "Data disk mounted successfully at $MOUNT_POINT"
else
    echo "Warning: Data disk not found, using default storage"
    MOUNT_POINT="/var/lib/postgresql"
fi

# Stop PostgreSQL to configure it
systemctl stop postgresql

# Configure PostgreSQL data directory
if [ "$MOUNT_POINT" != "/var/lib/postgresql" ]; then
    # Move PostgreSQL data to the mounted disk
    mkdir -p "$MOUNT_POINT/14/main"
    chown -R postgres:postgres "$MOUNT_POINT"
    
    # Update PostgreSQL configuration
    sed -i "s|#data_directory = 'ConfigDir'|data_directory = '$MOUNT_POINT/14/main'|" /etc/postgresql/14/main/postgresql.conf
    
    # Initialize the database cluster on the new location
    sudo -u postgres /usr/lib/postgresql/14/bin/initdb -D "$MOUNT_POINT/14/main"
fi

# Configure PostgreSQL
cat >> /etc/postgresql/14/main/postgresql.conf << EOF

# Custom configuration for DNS Lab
listen_addresses = '*'
port = 5432
max_connections = 100
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 1000
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on

# Performance monitoring
track_activities = on
track_counts = on
track_io_timing = on
track_functions = pl
EOF

# Configure client authentication
cat > /etc/postgresql/14/main/pg_hba.conf << EOF
# PostgreSQL Client Authentication Configuration File

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             postgres                                peer
local   all             all                                     peer

# IPv4 local connections:
host    all             all             127.0.0.1/32            md5

# IPv4 connections from VPC subnets
host    all             all             10.0.0.0/8              md5
host    all             all             172.16.0.0/12           md5
host    all             all             192.168.0.0/16          md5

# IPv6 local connections:
host    all             all             ::1/128                 md5

# Replication connections
local   replication     postgres                                peer
host    replication     postgres        127.0.0.1/32            md5
host    replication     postgres        ::1/128                 md5
EOF

# Start PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Wait for PostgreSQL to be ready
sleep 10

# Create database and user
sudo -u postgres psql << EOF
-- Create application database
CREATE DATABASE $DB_NAME;

-- Create application user
CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Create sample tables and data
\c $DB_NAME;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (name, email, role) VALUES
    ('John Doe', 'john@example.com', 'admin'),
    ('Jane Smith', 'jane@example.com', 'user'),
    ('Bob Johnson', 'bob@example.com', 'user'),
    ('Alice Brown', 'alice@example.com', 'moderator'),
    ('Charlie Wilson', 'charlie@example.com', 'user');

-- Application logs table
CREATE TABLE app_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    instance_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System metrics table
CREATE TABLE system_metrics (
    id SERIAL PRIMARY KEY,
    instance_name VARCHAR(100) NOT NULL,
    cpu_usage DECIMAL(5,2),
    memory_usage DECIMAL(5,2),
    disk_usage DECIMAL(5,2),
    network_in BIGINT,
    network_out BIGINT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grant permissions to application user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_app_logs_created_at ON app_logs(created_at);
CREATE INDEX idx_system_metrics_instance ON system_metrics(instance_name);
CREATE INDEX idx_system_metrics_recorded_at ON system_metrics(recorded_at);

-- Display database info
SELECT 'Database setup completed successfully' as status;
\l
\dt
EOF

# Create database backup script
cat > /usr/local/bin/db-backup.sh << EOF
#!/bin/bash
# Database backup script

BACKUP_DIR="/var/backups/postgresql"
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="\$BACKUP_DIR/$DB_NAME_\$DATE.sql"

# Create backup directory
mkdir -p \$BACKUP_DIR

# Create backup
sudo -u postgres pg_dump $DB_NAME > \$BACKUP_FILE

# Compress backup
gzip \$BACKUP_FILE

# Keep only last 7 days of backups
find \$BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "\$(date): Database backup completed: \$BACKUP_FILE.gz" >> /var/log/db-backup.log
EOF

chmod +x /usr/local/bin/db-backup.sh

# Create database monitoring script
cat > /usr/local/bin/db-monitor.sh << EOF
#!/bin/bash
# Database monitoring script

LOG_FILE="/var/log/db-monitor.log"

echo "\$(date): Database monitoring check" >> \$LOG_FILE

# Check PostgreSQL status
if systemctl is-active --quiet postgresql; then
    echo "\$(date): PostgreSQL is running" >> \$LOG_FILE
else
    echo "\$(date): ERROR - PostgreSQL is not running" >> \$LOG_FILE
    systemctl restart postgresql
fi

# Check database connectivity
if sudo -u postgres psql -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    echo "\$(date): Database connectivity OK" >> \$LOG_FILE
else
    echo "\$(date): ERROR - Database connectivity failed" >> \$LOG_FILE
fi

# Check disk space
DISK_USAGE=\$(df $MOUNT_POINT | awk 'NR==2 {print \$5}' | sed 's/%//')
if [ \$DISK_USAGE -gt 80 ]; then
    echo "\$(date): WARNING - Database disk usage is \$DISK_USAGE%" >> \$LOG_FILE
fi

# Log database statistics
DB_SIZE=\$(sudo -u postgres psql -d $DB_NAME -t -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));" | xargs)
CONNECTIONS=\$(sudo -u postgres psql -t -c "SELECT count(*) FROM pg_stat_activity;" | xargs)
echo "\$(date): Database size: \$DB_SIZE, Active connections: \$CONNECTIONS" >> \$LOG_FILE

# Insert system metrics
HOSTNAME=\$(hostname)
CPU_USAGE=\$(top -bn1 | grep "Cpu(s)" | awk '{print \$2}' | sed 's/%us,//')
MEMORY_USAGE=\$(free | awk 'NR==2{printf "%.2f", \$3*100/\$2}')
DISK_USAGE_PERCENT=\$(df $MOUNT_POINT | awk 'NR==2 {print \$5}' | sed 's/%//')

sudo -u postgres psql -d $DB_NAME -c "
INSERT INTO system_metrics (instance_name, cpu_usage, memory_usage, disk_usage) 
VALUES ('\$HOSTNAME', \$CPU_USAGE, \$MEMORY_USAGE, \$DISK_USAGE_PERCENT);
" >> \$LOG_FILE 2>&1
EOF

chmod +x /usr/local/bin/db-monitor.sh

# Create database health check endpoint
apt-get install -y python3 python3-pip
pip3 install flask psycopg2-binary

cat > /opt/db-health-server.py << EOF
#!/usr/bin/env python3
import json
import psycopg2
from flask import Flask, jsonify
from datetime import datetime
import os

app = Flask(__name__)

DB_CONFIG = {
    'host': 'localhost',
    'database': '$DB_NAME',
    'user': '$DB_USER',
    'password': '$DB_PASSWORD',
    'port': 5432
}

@app.route('/health')
def health_check():
    try:
        # Test database connection
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        cursor.execute("SELECT 1;")
        cursor.fetchone()
        cursor.close()
        conn.close()
        
        return jsonify({
            'status': 'healthy',
            'service': 'database',
            'instance': '${INSTANCE_NAME}',
            'timestamp': datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'service': 'database',
            'instance': '${INSTANCE_NAME}',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/status')
def status():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Get database statistics
        cursor.execute("SELECT pg_size_pretty(pg_database_size(%s));", (DB_CONFIG['database'],))
        db_size = cursor.fetchone()[0]
        
        cursor.execute("SELECT count(*) FROM pg_stat_activity;")
        connections = cursor.fetchone()[0]
        
        cursor.execute("SELECT count(*) FROM users;")
        user_count = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'status': 'running',
            'service': 'database',
            'instance': '${INSTANCE_NAME}',
            'database': {
                'name': DB_CONFIG['database'],
                'size': db_size,
                'connections': connections,
                'user_count': user_count
            },
            'timestamp': datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'service': 'database',
            'instance': '${INSTANCE_NAME}',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
EOF

chmod +x /opt/db-health-server.py

# Create systemd service for health server
cat > /etc/systemd/system/db-health.service << 'EOF'
[Unit]
Description=Database Health Check Server
After=postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=postgres
WorkingDirectory=/opt
ExecStart=/usr/bin/python3 /opt/db-health-server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start health check service
systemctl daemon-reload
systemctl enable db-health.service
systemctl start db-health.service

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 5432/tcp
    ufw allow 8080/tcp
    ufw --force enable
fi

# Add cron jobs
cat >> /etc/crontab << EOF
# Database backup (daily at 2 AM)
0 2 * * * root /usr/local/bin/db-backup.sh

# Database monitoring (every 5 minutes)
*/5 * * * * root /usr/local/bin/db-monitor.sh
EOF

# Log startup completion
echo "$(date): Database server startup script completed successfully" >> /var/log/startup.log

# Display connection information
echo "=== Database Setup Complete ===" | logger
echo "Database: $DB_NAME" | logger
echo "User: $DB_USER" | logger
echo "Instance: $INSTANCE_NAME" | logger
echo "Health check: http://$(hostname -I | awk '{print $1}'):8080/health" | logger

# Signal that startup is complete
echo "Database server startup completed on $INSTANCE_NAME" | logger