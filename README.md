## System Architecture

![AWS 3-Tier Architecture](./screenshot/System-Architecture.PNG)

AWS 3-Tier Infrastructure with Terraform & GitHub Actions (CI/CD).
This project builds a simple 3-tier architecture on AWS using Terraform.
Everything is modular, multi-AZ, and deployed through a lightweight CI/CD pipeline using GitHub Actions.
The goal is to show how I design and operate cloud infrastructure in a clean, reliable, and maintainable way.

## 1. Architecture Overview

The system follows a standard 3-tier layout with clear separation between network, compute, and load balancing layers.

**High Availability**
- Multi-AZ deployment
- Auto Scaling Groups replace unhealthy instances
- ALB/NLB distribute traffic across AZs
- No single-AZ dependency

**Network**
- VPC with public subnets (web tier + ALB) and private subnets (app + DB tiers)
- Internet Gateway + NAT Gateway
- Route tables per subnet group
- Multi-AZ subnet design

**Load Balancing**
- Application Load Balancer (Web tier, internet-facing)
- Network Load Balancer (App tier, internal)
- Independent health checks per target group

**Compute**
- Auto Scaling Groups for Web and App tiers
- EC2 instances bootstrapped via user-data
- Web tier: Apache reverse proxy → internal NLB → App tier (Flask) → RDS MySQL

**Security**
- Strict Security Group segmentation (SG-to-SG references, no broad CIDR rules)
- Only tier-to-tier traffic allowed
- IMDSv2 required on all instances
- EC2 IAM role limited to `AmazonSSMManagedInstanceCore` (Session Manager access, no SSH keys needed)
- DB password is never committed: injected via `TF_VAR_db_password` (GitHub secret) or a gitignored `terraform.tfvars`

## 2. Terraform Backend (S3 + DynamoDB)

The project uses a remote backend to ensure safe and consistent Terraform operations.
- S3 stores Terraform state (versioning + encryption enabled)
- DynamoDB provides state locking
- Prevents concurrent apply
- Matches real production setups

## 3. Repository Structure

```
/modules
  /vpc        # VPC, subnets, IGW, NAT GW, route tables
  /sg         # Security groups for all tiers
  /alb        # Internet-facing ALB (web tier)
  /nlb        # Internal NLB (app tier)
  /asg-web    # Web tier launch template + ASG
  /asg-app    # App tier launch template + ASG
  /rds        # MySQL RDS instance + subnet group
  /iam        # EC2 instance profile (SSM)
  /keypair    # EC2 key pair

/environments
  /dev        # Root module for the dev environment

/.github/workflows
  terraform-ci.yml       # fmt, validate, tflint, plan (push/PR)
  terraform-apply.yml    # manual apply (protected environment)
  terraform-destroy.yml  # manual destroy (protected environment + confirmation input)
```

Each module is self-contained and reusable. Environments are separated cleanly.

## 4. CI/CD Pipeline (GitHub Actions)

All workflows authenticate to AWS via **OIDC** (no long-lived access keys) and run against `environments/dev`.

**terraform-ci.yml** — runs on every push/PR:
- `terraform fmt -check`
- `terraform init` / `terraform validate`
- `tflint`
- `terraform plan` (plan uploaded as artifact)

**terraform-apply.yml** — manual deployment workflow:
- Gated behind the `dev` GitHub Environment (required reviewers)
- Runs `terraform apply` using the remote backend

**terraform-destroy.yml** — manual teardown workflow:
- Requires typing `destroy` as a confirmation input + environment approval
- Useful for temporary environments

Required repository configuration:
- GitHub secret `DB_PASSWORD` (used as `TF_VAR_db_password`)
- GitHub Environment `dev` with required reviewers (protects apply/destroy)
- IAM role `github-terraform-role` with a GitHub OIDC trust policy

## 5. Deployment Guide

Clone the repo:

```bash
git clone https://github.com/huynhtung98/eh01-aws-terraform-cicd
cd eh01-aws-terraform-cicd/environments/dev
```

Provide the DB password (never commit it):

```bash
export TF_VAR_db_password='your-strong-password'
```

Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## 6. What I Learned

This project helped me strengthen core CloudOps/SRE skills:
- Designing multi-AZ, highly available AWS architectures
- Structuring Terraform modules for clarity and reuse
- Building CI/CD pipelines for IaC with OIDC authentication
- Managing Terraform state with S3 + DynamoDB
- Handling secrets safely (no credentials in git)
- Debugging module dependencies and variable wiring
- Applying operational thinking to real infrastructure
