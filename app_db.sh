#!/bin/bash
set -e

# Update system packages
sudo dnf update -y
sudo dnf install -y python3 python3-pip

cd /tmp
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

cd /home/ec2-user
# Install Flask + PyMySQL
sudo pip3 install flask pymysql

# Start and enable SSM agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# --- Inject database endpoint from Terraform ---
echo "export DB_HOST=${DB_HOST}" | sudo tee -a /etc/profile
export DB_HOST=${DB_HOST}

# Create a simple Flask app with DB connection
cat <<'EOF' > /home/ec2-user/app.py
from flask import Flask
import pymysql, os

app = Flask(__name__)

@app.route('/')
def home():
    return f"<h2>Hello from App Server: {os.popen('hostname').read().strip()}</h2>"

@app.route('/db')
def db():
    try:
        conn = pymysql.connect(
            host=os.environ.get('DB_HOST'),
            user='admin',
            password='Elvin1234!',
            database='labdb',
            connect_timeout=3
        )
        with conn.cursor() as cursor:
            cursor.execute("SELECT NOW();")
            result = cursor.fetchone()
        conn.close() 
        return f"<h3>✅ Database connection successful: {result}</h3>"
    except Exception as e:
        return f"<h3>❌ Database connection failed: {e}</h3>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Run Flask in background
nohup python3 /home/ec2-user/app.py >/home/ec2-user/flask.log 2>&1 &
