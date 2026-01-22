#!/bin/bash

# Bastion Host Startup Script
# This script configures a secure bastion host for SSH access

set -e

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
    fail2ban \
    ufw \
    tree \
    vim \
    tmux \
    screen

# Install Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update
apt-get install -y google-cloud-cli

# Install Google Cloud Ops Agent for monitoring and logging
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Configure SSH hardening
cat >> /etc/ssh/sshd_config << 'EOF'

# Custom SSH hardening configuration
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60
EOF

# Restart SSH service
systemctl restart sshd

# Configure fail2ban
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

# Enable and start fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure UFW firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow out 22/tcp
ufw allow out 80/tcp
ufw allow out 443/tcp
ufw allow out 53
ufw --force enable

# Create bastion user for operations
useradd -m -s /bin/bash -G sudo bastion
mkdir -p /home/bastion/.ssh
chmod 700 /home/bastion/.ssh
chown bastion:bastion /home/bastion/.ssh

# Create welcome message
cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          GCP DNS Lab - Bastion Host                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  This is a secure bastion host for accessing internal resources.            ║
║                                                                              ║
║  Available commands:                                                         ║
║    • gcloud compute ssh <instance-name> --zone=<zone>                       ║
║    • gcloud compute instances list                                           ║
║    • nslookup <hostname>                                                     ║
║    • dig <hostname>                                                          ║
║                                                                              ║
║  Internal DNS zones:                                                         ║
║    • web-1.internal.example.com                                             ║
║    • app-1.internal.example.com                                             ║
║    • db-1.internal.example.com                                              ║
║                                                                              ║
║  Security features enabled:                                                  ║
║    • SSH key-only authentication                                             ║
║    • Fail2ban intrusion prevention                                           ║
║    • UFW firewall                                                            ║
║    • Session logging                                                         ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

# Create useful aliases
cat > /etc/profile.d/bastion-aliases.sh << 'EOF'
# Bastion host aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# GCP aliases
alias gci='gcloud compute instances'
alias gcil='gcloud compute instances list'
alias gcs='gcloud compute ssh'
alias gcz='gcloud compute zones list'
alias gcr='gcloud compute regions list'

# DNS aliases
alias nsl='nslookup'
alias dnstest='dig +short'

# Network aliases
alias ports='netstat -tulanp'
alias listening='ss -tuln'
alias connections='ss -tup'

# System aliases
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -E'
alias top='htop'

# Log aliases
alias logs='journalctl -f'
alias syslog='tail -f /var/log/syslog'
alias authlog='tail -f /var/log/auth.log'
EOF

# Create connection helper scripts
cat > /usr/local/bin/connect-web << 'EOF'
#!/bin/bash
echo "Connecting to web server..."
gcloud compute ssh dns-lab-web-1 --zone=us-central1-a --tunnel-through-iap
EOF

cat > /usr/local/bin/connect-app << 'EOF'
#!/bin/bash
echo "Connecting to app server..."
gcloud compute ssh dns-lab-app-1 --zone=us-central1-a --tunnel-through-iap
EOF

cat > /usr/local/bin/connect-db << 'EOF'
#!/bin/bash
echo "Connecting to database server..."
gcloud compute ssh dns-lab-db-1 --zone=us-central1-a --tunnel-through-iap
EOF

chmod +x /usr/local/bin/connect-*

# Create DNS testing script
cat > /usr/local/bin/dns-test << 'EOF'
#!/bin/bash
echo "=== DNS Lab Testing Script ==="
echo

echo "Testing internal DNS resolution:"
echo "--------------------------------"
for host in web-1 app-1 db-1; do
    echo -n "Testing $host.internal.example.com: "
    if nslookup $host.internal.example.com > /dev/null 2>&1; then
        IP=$(nslookup $host.internal.example.com | grep "Address:" | tail -1 | awk '{print $2}')
        echo "✓ Resolved to $IP"
    else
        echo "✗ Failed to resolve"
    fi
done

echo
echo "Testing external DNS resolution:"
echo "--------------------------------"
for host in google.com cloudflare.com; do
    echo -n "Testing $host: "
    if nslookup $host > /dev/null 2>&1; then
        echo "✓ Resolved"
    else
        echo "✗ Failed to resolve"
    fi
done

echo
echo "Testing connectivity to internal services:"
echo "------------------------------------------"
for host in web-1 app-1 db-1; do
    FQDN="$host.internal.example.com"
    echo -n "Testing connectivity to $FQDN: "
    if ping -c 1 -W 2 $FQDN > /dev/null 2>&1; then
        echo "✓ Reachable"
    else
        echo "✗ Unreachable"
    fi
done
EOF

chmod +x /usr/local/bin/dns-test

# Create system monitoring script
cat > /usr/local/bin/system-status << 'EOF'
#!/bin/bash
echo "=== Bastion Host System Status ==="
echo
echo "System Information:"
echo "-------------------"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | awk 'NR==2{printf "%.1f%% (%s/%s)", $3*100/$2, $3, $2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{printf "%s (%s)", $5, $4}')"
echo

echo "Network Information:"
echo "--------------------"
echo "Internal IP: $(hostname -I | awk '{print $1}')"
echo "External IP: $(curl -s ifconfig.me)"
echo

echo "Active SSH Sessions:"
echo "--------------------"
who

echo
echo "Recent Failed Login Attempts:"
echo "------------------------------"
grep "Failed password" /var/log/auth.log | tail -5 | awk '{print $1, $2, $3, $11, $13}'

echo
echo "Fail2ban Status:"
echo "----------------"
fail2ban-client status sshd 2>/dev/null || echo "Fail2ban not active"
EOF

chmod +x /usr/local/bin/system-status

# Create log monitoring script
cat > /usr/local/bin/bastion-monitor.sh << 'EOF'
#!/bin/bash
# Bastion host monitoring script

LOG_FILE="/var/log/bastion-monitor.log"

echo "$(date): Bastion monitoring check" >> $LOG_FILE

# Check SSH service
if systemctl is-active --quiet sshd; then
    echo "$(date): SSH service is running" >> $LOG_FILE
else
    echo "$(date): ERROR - SSH service is not running" >> $LOG_FILE
    systemctl restart sshd
fi

# Check fail2ban
if systemctl is-active --quiet fail2ban; then
    echo "$(date): Fail2ban is running" >> $LOG_FILE
else
    echo "$(date): ERROR - Fail2ban is not running" >> $LOG_FILE
    systemctl restart fail2ban
fi

# Check UFW firewall
if ufw status | grep -q "Status: active"; then
    echo "$(date): UFW firewall is active" >> $LOG_FILE
else
    echo "$(date): WARNING - UFW firewall is not active" >> $LOG_FILE
fi

# Log active sessions
SESSIONS=$(who | wc -l)
echo "$(date): Active SSH sessions: $SESSIONS" >> $LOG_FILE

# Check for suspicious activity
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log | grep "$(date '+%b %d')" | wc -l)
if [ $FAILED_LOGINS -gt 10 ]; then
    echo "$(date): WARNING - High number of failed login attempts: $FAILED_LOGINS" >> $LOG_FILE
fi
EOF

chmod +x /usr/local/bin/bastion-monitor.sh

# Add monitoring script to cron
echo "*/10 * * * * root /usr/local/bin/bastion-monitor.sh" >> /etc/crontab

# Configure session logging
cat >> /etc/bash.bashrc << 'EOF'

# Session logging for bastion host
if [ "$PS1" ]; then
    HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
    HISTSIZE=10000
    HISTFILESIZE=10000
    HISTCONTROL=ignoredups:ignorespace
    shopt -s histappend
    
    # Log all commands to syslog
    export PROMPT_COMMAND='history -a; logger -p local0.info "BASTION_CMD: $(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//")"'
fi
EOF

# Create rsyslog configuration for command logging
cat > /etc/rsyslog.d/50-bastion.conf << 'EOF'
# Bastion host command logging
local0.info /var/log/bastion-commands.log
& stop
EOF

systemctl restart rsyslog

# Create logrotate configuration
cat > /etc/logrotate.d/bastion << 'EOF'
/var/log/bastion-*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0644 root root
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF

# Set up automatic security updates
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# Log startup completion
echo "$(date): Bastion host startup script completed successfully" >> /var/log/startup.log

# Display setup information
echo "=== Bastion Host Setup Complete ===" | logger
echo "SSH hardening enabled" | logger
echo "Fail2ban configured" | logger
echo "UFW firewall active" | logger
echo "Session logging enabled" | logger
echo "Monitoring scripts installed" | logger

# Signal that startup is complete
echo "Bastion host startup completed" | logger