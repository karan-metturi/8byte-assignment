# 🚀 8Byte DevOps Assignment: Backend Infrastructure on AWS

## Project Summary: Cloud-Native Backend Deployment

This project successfully provisions a complete, production-ready backend infrastructure on **Amazon Web Services (AWS)**. It utilizes **Terraform** for full Infrastructure as Code (IaC), deploys a Python Flask application using **AWS ECS Fargate**, and automates the entire deployment lifecycle via **GitHub Actions CI/CD**.

The solution prioritizes **clean architecture**, **reproducible infrastructure**, **security best practices**, and **cost efficiency**.

---

## 1. Cloud Architecture & Design Decisions

### 1.1 Solution Overview
The application is deployed using a highly available, serverless container architecture. The key components are:
* **Compute:** AWS ECS Fargate (Serverless Containers)
* **Database:** Amazon RDS (PostgreSQL)
* **Networking:** Application Load Balancer (ALB) and custom VPC with private/public subnets
* **IaC:** HashiCorp Terraform
* **CI/CD:** GitHub Actions



### 1.2 Architecture Rationale

| Component | Technology Selected | Rationale |
| :--- | :--- | :--- |
| **Container Compute** | **ECS Fargate** | **Fully Serverless**; eliminates EC2 management and patching overhead. Ideal for stateless, containerized applications. Simpler and more cost-effective than EKS for this scope. |
| **Networking** | **Private Subnets** | **Security First**. ECS Tasks and RDS are deployed in private subnets, ensuring no direct internet access. Only the ALB is internet-facing. |
| **Database** | **RDS PostgreSQL** | **Managed Service** for automated backups, multi-AZ failover, and performance monitoring. Ensures high reliability and minimal operational burden. |
| **Infrastructure** | **Terraform (IaC)** | Enables **modular, reusable infrastructure** with version control. Uses an S3 backend for robust remote state management and DynamoDB for state locking (team collaboration). |
| **Automation** | **GitHub Actions** | Provides a seamless, end-to-end CI/CD workflow mirroring real-world practices (Test $\rightarrow$ Build $\rightarrow$ Deploy Staging $\rightarrow$ Manual Approval $\rightarrow$ Deploy Prod). |

---

## 2. Infrastructure Setup & Deployment Guide

### 2.1 Prerequisites

Ensure the following tools and AWS setup are configured prior to deployment:

| Tool/Service | Required Version | Notes |
| :--- | :--- | :--- |
| **Terraform** | $\ge 1.5$ | For Infrastructure as Code (IaC). |
| **AWS CLI** | $\ge 2.0$ | For connecting to the AWS environment. |
| **Docker** | Latest | To build and push the application image. |
| **Remote State** | S3 Bucket + DynamoDB | Bucket: `prop-terraform-state`, Table: `prop-terraform-locks`. |
| **AWS Account** | | Required permissions for VPC, ECS, ECR, RDS, IAM, CloudWatch. |

### 2.2 Terraform Deployment Steps

The infrastructure is provisioned from the `infra/terraform/` directory.

1.  **Clone & Navigate:**
    ```bash
    git clone [https://github.com/](https://github.com/)<your-username>/<repo-name>.git
    cd <repo-name>/infra/terraform
    ```
2.  **Initialize Backend:**
    ```bash
    terraform init -reconfigure
    ```
    *This command configures the S3 remote backend and DynamoDB state lock.*
3.  **Validate & Plan:** Review and approve the changes before applying.
    ```bash
    terraform fmt
    terraform validate
    terraform plan
    ```
4.  **Apply Infrastructure:**
    ```bash
    terraform apply
    ```
    **Key Resources Built:** VPC, Public/Private Subnets, ALB, Security Groups (ALB, ECS, RDS), RDS PostgreSQL instance.

### 2.3 Container Build & Push

1.  **Build Docker Image:**
    ```bash
    cd app/backend
    docker build -t karan-ecs-backend .
    ```
2.  **Tag & Push to ECR:** Authenticate with AWS ECR, then tag and push the image.
    ```bash
    docker tag karan-ecs-backend:latest <aws_account>[.dkr.ecr.ap-south-1.amazonaws.com/karan-ecs-backend:latest](https://.dkr.ecr.ap-south-1.amazonaws.com/karan-ecs-backend:latest)
    docker push <aws_account>[.dkr.ecr.ap-south-1.amazonaws.com/karan-ecs-backend:latest](https://.dkr.ecr.ap-south-1.amazonaws.com/karan-ecs-backend:latest)
    ```

### 2.4 Final Application Access

The ECS Cluster (`prop-ecs-cluster`) and Service (`prop-backend-service`) were configured via the ECS Console (simple assignment setup) to utilize the image from ECR and the provisioned network resources.

The application is accessible via the Application Load Balancer DNS name:
`http://<alb-dns-name>`

---

## 3. Security & Compliance

Robust security was a core focus, implemented across networking and credentials.

### 3.1 Security Groups (Layered Defense)
Security groups enforce a strict, zero-trust network model between components:
* **ALB SG:** Allows port **80** from the internet (`0.0.0.0/0`).
* **ECS SG:** Allows port **80** *only* from the **ALB SG**.
* **RDS SG:** Allows port **5432** (PostgreSQL) *only* from the **ECS SG**.

### 3.2 Secrets Management
* **GitHub Secrets:** Used for storing environment-specific credentials like `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `SLACK_WEBHOOK` for CI/CD.
* **Terraform Variables:** Database credentials are provided via variables, ensuring they are **never committed** to the repository.
* **IAM Roles:** Used for ECS Task Execution and CI/CD operations, adhering to the principle of least privilege.

### 3.3 Network Isolation
ECS Tasks and RDS run exclusively in **private subnets**, protected from all direct, external internet access.

---

## 4. Cost Optimization Measures

The design focused on maximizing the use of cost-efficient and serverless services.

* ✅ **AWS Fargate:** Eliminates all costs associated with managing and running underlying EC2 instances. Pay only for container resource usage.
* ✅ **Small RDS Instance:** Used `db.t3.micro` with 20GB storage, aligning with AWS Free Tier constraints and minimizing database costs.
* ✅ **No NAT Gateway:** Omitted the NAT Gateway since ECS tasks do not require outbound internet access for this specific backend assignment, resulting in a significant monthly cost saving (~₹3000/month).
* ✅ **Minimal Scaling:** ECS Service is set to run only 1 task for the assignment, avoiding unnecessary scaling charges.
* ✅ **CloudWatch:** Used for all logging and monitoring, avoiding expensive third-party tools.

---

## 5. Backup & Observability

### 5.1 Backup Strategy (RDS)
The RDS instance utilizes **AWS-managed Automated Backups**, satisfying the project's data recovery requirement:
* Daily snapshots.
* Point-in-time restore (PITR) up to the configured retention period.

### 5.2 CI/CD Pipeline Flow
The GitHub Actions pipeline (`.github/workflows/ci-cd.yml`) implements a modern, controlled deployment:

1.  **Test on PR:** Runs unit/integration tests and vulnerability scans.
2.  **Build & Push:** Creates the Docker image and pushes to ECR.
3.  **Deploy Staging:** Deploys the new image to a staging ECS environment.
4.  **Manual Approval Gate**
5.  **Deploy Production:** Deploys the change to the production ECS environment.

***

## Project Conclusion

This project successfully integrates **Infrastructure as Code (Terraform)**, **Containerization (Docker/ECR)**, and **Serverless Deployment (ECS Fargate)**, all orchestrated through a robust **GitHub Actions CI/CD pipeline**. The solution is **modular, reproducible, secure, and cost-efficient**, demonstrating proficiency in full-stack DevOps methodology.