#!/bin/bash
set -e

# Update system packages
sudo dnf update -y
sudo dnf install -y python3 python3-pip

# SSM agent is preinstalled on Amazon Linux 2023; make sure it is running
sudo systemctl enable --now amazon-ssm-agent

# Install Flask + PyMySQL
sudo pip3 install flask pymysql

# --- Inject database connection info from Terraform ---
# Stored in a root-only env file instead of /etc/profile so credentials are
# not exposed to every user on the instance.
sudo bash -c "cat > /etc/app.env" <<EOF
DB_HOST=${DB_HOST}
DB_NAME=${DB_NAME}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
EOF
sudo chmod 600 /etc/app.env

# Create a simple Flask app with DB connection
cat <<'EOF' > /home/ec2-user/app.py
from flask import Flask
import pymysql, os, socket

app = Flask(__name__)

@app.route('/')
def home():
    return f"<h2>Hello from App Server: {socket.gethostname()}</h2>"

@app.route('/db')
def db():
    try:
        conn = pymysql.connect(
            host=os.environ.get('DB_HOST'),
            user=os.environ.get('DB_USERNAME'),
            password=os.environ.get('DB_PASSWORD'),
            database=os.environ.get('DB_NAME'),
            connect_timeout=3
        )
        with conn.cursor() as cursor:
            cursor.execute("SELECT NOW();")
            result = cursor.fetchone()
        conn.close()
        return f"<h3>Database connection successful: {result}</h3>"
    except Exception as e:
        return f"<h3>Database connection failed: {e}</h3>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Run Flask as a systemd service so it survives reboots and crashes
sudo bash -c "cat > /etc/systemd/system/flask-app.service" <<'EOF'
[Unit]
Description=Flask demo app
After=network.target

[Service]
User=ec2-user
EnvironmentFile=/etc/app.env
ExecStart=/usr/bin/python3 /home/ec2-user/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now flask-app
