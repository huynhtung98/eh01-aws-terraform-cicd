## System Architecture

![AWS 3-Tier Architecture](./screenshot/System-Architecture.PNG)

AWS 3 Tier Infrastructure with Terraform & GitHub Actions (CI/CD)
This project builds a simple 3 tier architecture on AWS using Terraform.
Everything is modular, runs across multiple AZs, and is deployed through a small CI/CD pipeline using GitHub Actions.
The goal is to show how I design, structure, and operate cloud infrastructure in a clean and reliable way — the same approach I use in CloudOps/SRE work.

1. Architecture Overview
The system follows a standard 3 tier layout with clear separation between network, compute, and load balancing layers.
High Availability
•	All components run across multiple Availability Zones
•	Auto Scaling Groups replace unhealthy instances automatically
•	ALB/NLB distribute traffic across AZs
•	No single AZ dependency
Network
•	VPC with public + private subnets
•	Internet Gateway + NAT Gateway
•	Route tables per subnet group
•	Multi AZ subnet design
Load Balancing
•	ALB for the Web tier
•	NLB for the App tier
•	Independent health checks for each tier
Compute
•	Auto Scaling Groups for Web and App
•	EC2 instances bootstrapped via user data
•	Multi AZ deployment for resilience
Security
•	Strict Security Group segmentation
•	Only tier to tier traffic allowed
•	No broad or open access

2. Terraform Backend (S3 + DynamoDB)
The project uses a remote backend to keep Terraform operations safe and consistent.
•	S3 for storing state (versioning + encryption enabled)
•	DynamoDB for state locking
•	Prevents concurrent apply
•	Matches how real teams manage IaC in production

3. Repository Structure

/modules
  /vpc
  /alb
  /nlb
  /web
  /app
  /asg
  /sg

/environments
  /dev

/.github/workflows
  terraform-ci.yml
  terraform-apply.yml
  terraform-destroy.yml

README.md
Each module is self contained and easy to reuse.
Environments (dev, prod) are separated cleanly.

4. CI/CD Pipeline (GitHub Actions)
The pipeline is split into three workflows, each with a single responsibility.
terraform-ci.yml
Runs on every push/PR:
•	terraform fmt
•	terraform validate
•	terraform init
•	terraform plan
Ensures changes are clean and safe before deployment.
terraform-apply.yml
Manual deployment workflow:
•	Runs terraform apply using the remote backend
•	Used for controlled, auditable releases
terraform-destroy.yml
Manual teardown workflow:
•	Runs terraform destroy
•	Useful for temporary environments

5. Deployment Guide
Clone the repo:
git clone https://github.com/huynhtung98/eh01-aws-terraform-cicd
Navigate to an environment:
cd environments/dev
Deploy:
terraform init
terraform apply

6. What I Learned
This project helped me sharpen skills that are core to CloudOps/SRE work:
•	Designing multi AZ, highly available AWS architectures
•	Structuring Terraform modules for clarity and reuse
•	Building CI/CD pipelines for IaC
•	Managing Terraform state with S3 + DynamoDB
•	Debugging module dependencies and variable wiring
•	Applying operational thinking to real infrastructure

7. Why This Project Matters
It reflects how I approach infrastructure work:
•	Architecture is simple, reliable, and multi AZ
•	Terraform is modular and predictable
•	CI/CD ensures safe, repeatable deployments
•	State is managed properly for team use
•	Security is built into every layer
•	The structure matches how real production systems are run


