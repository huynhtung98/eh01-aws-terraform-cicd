#!/bin/bash
set -e

# Update system packages
sudo dnf update -y

# Install Python 3
sudo dnf install -y python3

# Create a simple HTML response
sudo cat <<EOF > /home/ec2-user/index.html
<html>
  <head><title>App Server</title></head>
  <body>
    <h1>Hello from App Server: $(hostname)</h1>
    <p>Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</p>
  </body>
</html>
EOF

# Run Python simple HTTP server on port 8080 in background
nohup python3 -m http.server 8080 --directory /home/ec2-user >/home/ec2-user/http.log 2>&1 &
