<img width="1018" height="1359" alt="image" src="https://github.com/user-attachments/assets/c188b2ae-6604-4e9d-9ff1-835addac25a4" />

# AWS 3-Tier Architecture Deployment with Terraform

This project is my hands-on build of a 3-tier architecture on AWS using Terraform.

I created it to practise deploying a more realistic cloud environment instead of a basic single-tier setup. The infrastructure is separated into web, application, and database layers across two Availability Zones, with load balancing, auto scaling, private networking, and managed database services included.

The web tier runs Apache on EC2 instances in public subnets and is exposed through an internet-facing Application Load Balancer.  
The application tier runs a Flask backend on EC2 instances in private subnets behind an internal Network Load Balancer.  
The database tier uses Amazon RDS MySQL in private subnets with Multi-AZ enabled.

I also configured the supporting AWS components needed to make the environment work properly, including the VPC, public and private subnets, route tables, Internet Gateway, NAT Gateway, security groups, IAM roles, VPC endpoints, and a bastion host for administration.

This project helped me practise not just Terraform itself, but also how a 3-tier design is actually structured in AWS — how traffic flows between layers, how private resources are protected, and how different services connect in a way that is closer to a real deployment.

---

## Architecture Overview

The infrastructure is split into three layers:

### Web Tier
- EC2 instances running Apache
- Deployed in public subnets
- Fronted by an internet-facing Application Load Balancer
- Managed by an Auto Scaling Group

### Application Tier
- EC2 instances running a Flask application
- Deployed in private subnets
- Fronted by an internal Network Load Balancer
- Accessed only from the web tier

### Database Tier
- Amazon RDS MySQL
- Deployed in private subnets
- Configured with Multi-AZ for better availability
- Accessible only from the application tier

---

## Supporting Components

- Custom VPC across two Availability Zones
- Public and private subnets
- Internet Gateway and NAT Gateway
- Route tables and route associations
- Security groups between tiers
- IAM roles and instance profiles
- VPC endpoints for SSM and S3
- Bastion host for administrative access

---

## Terraform Structure

The Terraform configuration is organised by component:

- `provider.tf` – provider configuration
- `vpc1.tf` – VPC, subnets, routing, gateways, and networking
- `web.tf` – web tier resources
- `app.tf` – application tier resources
- `db.tf` – database tier resources
- `vpc_endpoints.tf` – VPC endpoints
- `iam.tf` – IAM roles and policies
- `keypair.tf` – key pair configuration
- `output.tf` – Terraform outputs

---

## What I Practised in This Project

Through this project, I got hands-on experience with:

- Building a multi-tier AWS environment using Terraform
- Designing public and private subnet separation
- Configuring ALB, NLB, and Auto Scaling Groups
- Deploying a Flask app behind internal load balancing
- Setting up RDS MySQL in private subnets
- Controlling traffic flow between tiers with security groups
- Using VPC endpoints and IAM roles to reduce direct public access
- Structuring Terraform files for a clearer deployment layout
