#!/bin/bash

set -e
#Update all package repositories
sudo dnf update -y
sudo dnf install net-tools -y

cd /tmp
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

cd /home/ec2-user
#Install Apache web server
sudo dnf install -y httpd

#Start and Enable Apache web server

sudo systemctl enable httpd

# Start and enable SSM agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

#Retrive EC2 instance public ipv4 metadata
publicipv4=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4)

# Create basic index.html page
sudo bash -c 'cat <<EOF > /var/www/html/index.html
<html>
  <head><title>Web Server</title></head>
  <body>
    <h1>Hello from Web Server: $(hostname)</h1>
    <p>Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</p>
  </body>
</html>
EOF'


# Add Reverse Proxy configuration to Apache
sudo tee -a /etc/httpd/conf/httpd.conf > /dev/null <<'EOF'

ProxyRequests Off
ProxyPreserveHost On
<Proxy *>
    Require all granted
</Proxy>

# Forward requests from /app to Flask app via internal NLB
ProxyPass /app http://${NLB_DNS}:8080/
ProxyPassReverse /app http://${NLB_DNS}:8080/
EOF

# Restart Apache to apply new configuration



echo "✅ Apache setup complete. Web + Reverse Proxy active."

sudo setsebool -P httpd_can_network_connect 1

sudo systemctl restart httpd