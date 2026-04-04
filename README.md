## System Architecture

![AWS 3-Tier Architecture](./screenshot/System-Architecture.PNG)

AWS 3‑Tier Infrastructure with Terraform & GitHub Actions (CI/CD)
This project builds a simple, production‑style 3‑tier architecture on AWS using Terraform.
Everything is modular, multi‑AZ, and deployed through a lightweight CI/CD pipeline using GitHub Actions.
The goal is to show how I design and operate cloud infrastructure in a clean, reliable, and maintainable way — the same approach I use in CloudOps/SRE work.

1. Architecture Overview
The system follows a standard 3‑tier layout with clear separation between network, compute, and load balancing layers.
High Availability
- Multi‑AZ deployment
- Auto Scaling Groups replace unhealthy instances
- ALB/NLB distribute traffic across AZs
- No single‑AZ dependency
Network
- VPC with public + private subnets
- Internet Gateway + NAT Gateway
- Route tables per subnet group
- Multi‑AZ subnet design
Load Balancing
- Application Load Balancer (Web tier)
- Network Load Balancer (App tier)
- Independent health checks
Compute
- Auto Scaling Groups for Web and App
- EC2 instances bootstrapped via user‑data
- Multi‑AZ deployment
Security
- Strict Security Group segmentation
- Only tier‑to‑tier traffic allowed
- No broad or open access

2. Terraform Backend (S3 + DynamoDB)
The project uses a remote backend to ensure safe and consistent Terraform operations.
- S3 stores Terraform state (versioning + encryption enabled)
- DynamoDB provides state locking
- Prevents concurrent apply
- Matches real production setups

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
  /prod

/.github/workflows
  terraform-ci.yml
  terraform-apply.yml
  terraform-destroy.yml

README.md


Each module is self‑contained and reusable.
Environments (dev, prod) are separated cleanly.

4. CI/CD Pipeline (GitHub Actions)
The pipeline is split into three workflows, each with a single responsibility.
terraform-ci.yml
Runs on every push/PR:
- terraform fmt
- terraform validate
- terraform init
- terraform plan
Ensures changes are clean and safe before deployment.
terraform-apply.yml
Manual deployment workflow:
- Runs terraform apply using the remote backend
- Used for controlled, auditable releases
terraform-destroy.yml
Manual teardown workflow:
- Runs terraform destroy
- Useful for temporary environments

5. Deployment Guide
Clone the repo:
git clone https://github.com/huynhtung98/eh01-aws-terraform-cicd


Navigate to an environment:
cd environments/dev


Deploy:
terraform init
terraform apply



6. What I Learned
This project helped me strengthen core CloudOps/SRE skills:
- Designing multi‑AZ, highly available AWS architectures
- Structuring Terraform modules for clarity and reuse
- Building CI/CD pipelines for IaC
- Managing Terraform state with S3 + DynamoDB
- Debugging module dependencies and variable wiring
- Applying operational thinking to real infrastructure



