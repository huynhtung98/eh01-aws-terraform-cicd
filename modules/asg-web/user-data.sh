#!/bin/bash
set -e

# Update all package repositories
sudo dnf update -y
sudo dnf install -y net-tools httpd

# Enable Apache web server
sudo systemctl enable httpd

# SSM agent is preinstalled on Amazon Linux 2023; make sure it is running
sudo systemctl enable --now amazon-ssm-agent

# Retrieve EC2 instance metadata (IMDSv2)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IPV4=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
HOST_NAME=$(hostname)

# Create basic index.html page
sudo bash -c "cat > /var/www/html/index.html" <<EOF
<html>
  <head><title>Web Server</title></head>
  <body>
    <h1>Hello from Web Server: $HOST_NAME</h1>
    <p>Public IP: $PUBLIC_IPV4</p>
  </body>
</html>
EOF

# Add Reverse Proxy configuration to Apache
sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null <<EOF

ProxyRequests Off
ProxyPreserveHost On
<Proxy *>
    Require all granted
</Proxy>

# Forward requests from /app to Flask app via internal NLB
ProxyPass /app http://${NLB_DNS}:8080/
ProxyPassReverse /app http://${NLB_DNS}:8080/
EOF

# Allow Apache to make outbound network connections (SELinux)
sudo setsebool -P httpd_can_network_connect 1

# Restart Apache to apply new configuration
sudo systemctl restart httpd

echo "Apache setup complete. Web + Reverse Proxy active."
