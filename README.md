8Byte DevOps Assignment - Backend on AWS (ECS Fargate + Terraform + CI/CD)

This project provisions a complete backend infrastructure on AWS using Terraform, deploys a Python Flask application using AWS ECS Fargate, stores data in Amazon RDS (PostgreSQL), exposes the service through an Application Load Balancer, and automates deployments using GitHub Actions CI/CD pipelines.

The project was built with a focus on clean architecture, reproducible infrastructure, security best practices, and cost efficiency.

 1. How to Set Up & Run the Infrastructure
1.1 Prerequisites

Before deploying the infrastructure, ensure the following tools are installed:

Tool	Version
Terraform	>= 1.5
AWS CLI	>= 2.0
Docker	Latest
GitHub Actions	Enabled on your repo

AWS requirements:

AWS account with permissions for VPC, ECS, ECR, RDS, IAM, and CloudWatch

S3 bucket and DynamoDB table for Terraform remote state
Bucket: prop-terraform-state
DynamoDB Table: prop-terraform-locks

1.2 Clone the repository
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>/infra/terraform

1.3 Update Terraform variables (if needed)

Edit:

infra/terraform/variables.tf


Key variables include:

VPC CIDR

Subnet CIDRs

DB credentials

AWS region

1.4 Initialize Terraform
terraform init -reconfigure


This configures the S3 backend + DynamoDB lock table.

1.5 Validate & Apply Infrastructure
terraform fmt
terraform validate
terraform plan
terraform apply


Terraform builds:

VPC
Public & Private Subnets
Internet Gateway
Public Route Table
Security Groups (ALB, ECS, RDS)
RDS PostgreSQL
Outputs for ECS + RDS

1.6 Build & Push Docker Image to ECR
cd app/backend
docker build -t karan-ecs-backend .
docker tag karan-ecs-backend:latest <aws_account>.dkr.ecr.ap-south-1.amazonaws.com/karan-ecs-backend:latest
docker push <aws_account>.dkr.ecr.ap-south-1.amazonaws.com/karan-ecs-backend:latest

1.7 Deploy ECS Service

The ECS Cluster and Service were created through the ECS console (simple setup for assignment):

Cluster: prop-ecs-cluster

Service: prop-backend-service

Task Definition: Uses container image from ECR

Network: Private subnets + ECS security group

Load Balancer: ALB in public subnets

Once applied, access app via ALB DNS:

http://<alb-dns-name>

2. Architecture Decisions
2.1 Why ECS Fargate?

I selected AWS ECS Fargate because:

Fully serverless -> no EC2 management

Simplifies scaling

Ideal for stateless containerized apps

Integrates cleanly with ECR + ALB + CloudWatch

EKS is more complex and unnecessary for a small backend service.

2.2 Network Architecture

Public Subnets-> hold the ALB (internet-facing).

Private Subnets -> hold ECS tasks + RDS database.

No direct internet exposure for containers or DB.

Traffic path:

Internet -> ALB -> ECS Task -> RDS


This ensures proper isolation and security.

2.3 RDS PostgreSQL

A managed database service provides:

Automated backups

Multi-AZ failover capability

Performance monitoring

A private subnet deployment ensures DB stays internal.

2.4 Terraform for IaC

Why Terraform?

Modular, reusable infrastructure

Version-controlled setup

Safe change previews (terraform plan)

S3 backend ensures team collaboration + state locking

2.5 GitHub Actions for CI/CD

A single .github/workflows/ci-cd.yml pipeline automates:

Test on PR

Scan code for vulnerabilities

Build & push Docker image

Deploy to ECS Staging

Manual approval -> Deploy to Production

Matches real-world DevOps workflow.

 3. Security Considerations
3.1 Security Groups

ALB SG allows only port 80 from the world.

ECS SG allows only port 80 from ALB.

RDS SG allows only port 5432 from ECS.

No broad access between layers.

3.2 Secrets Management

Implemented using GitHub Secrets:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

SLACK_WEBHOOK

DB password stored as Terraform variable (never committed)

No secrets in code.

3.3 Private Subnets

ECS tasks & RDS run in private subnets -> protected from internet.

3.4 IAM Best Practices

ECS Task Execution Role used only for ECR pull + CloudWatch

Terraform uses limited-permission IAM user for state

 4. Cost Optimization Measures
4.1 Use of Fargate

Fargate removes EC2 cost overhead; you pay only for container runtime.

4.2 Small RDS Instance

Used:

db.t3.micro
20GB storage


This fits AWS Free Tier and keeps billing minimal.

4.3 No NAT Gateway

Since this is a backend assignment and ECS tasks do not need outbound internet, I avoided creating a NAT Gateway -> instantly saves ~₹3000/month.

4.4 Auto-Stop Unused Resources

RDS can be stopped outside working hours (optional).

ECS service runs only 1 task -> no scaling cost.

4.5 Logging & Monitoring

CloudWatch dashboards used instead of expensive external monitoring tools.

 5. Backup Strategy
 Implemented RDS Automated Backups

RDS instance uses AWS-managed backups:

Daily snapshots

Point-in-time restore

PITR up to retention period

No manual work needed

This satisfies the backup requirement.

(Optional: could add Terraform-managed snapshots.)

 6. Secret Management (Assignment Requirement Covered)

 GitHub Secrets
 Terraform variables for DB credentials
 No secrets stored in repository
 IAM roles instead of access keys where possible

 Summary

This project demonstrates:

Infrastructure as Code using Terraform

Containerization + Docker best practices

Deployment on ECS Fargate

GitHub Actions CI/CD following real DevOps standards

Secure network architecture

Monitoring, logging, backup, and cost optimization

Everything is modular, reproducible, and production-ready.