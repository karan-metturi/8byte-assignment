# 🚀 8Byte DevOps Assignment: Technical Report

## I. Project Summary: Cloud-Native Backend Deployment

This project successfully provisions a complete, production-ready backend infrastructure on **Amazon Web Services (AWS)**. It utilizes **Terraform** for full Infrastructure as Code (IaC), deploys a Python Flask application using **AWS ECS Fargate**, and automates the entire deployment lifecycle via **GitHub Actions CI/CD**.

The solution prioritizes **clean architecture**, **reproducible infrastructure**, **security best practices**, and **cost efficiency**.

### Architecture Overview

The application uses a highly available, serverless container architecture.

* **Compute:** AWS ECS Fargate (Serverless Containers)
* **Database:** Amazon RDS (PostgreSQL)
* **Networking:** Application Load Balancer (ALB) and custom VPC with private/public subnets
* **IaC:** HashiCorp Terraform
* **CI/CD:** GitHub Actions



---

## II. My Thought Process & Implementation Strategy

This section outlines the architectural decisions and implementation reasoning, mirroring **real-world DevOps practices**.

### 2.1 Strategic Rationale

| Component | Technology Selected | Key Rationale |
| :--- | :--- | :--- |
| **Compute** | **ECS Fargate** | Fully Serverless; eliminates EC2 management overhead. |
| **Infrastructure** | **Terraform (IaC)** | Modular, reusable, and uses S3 backend for state locking. |
| **Networking** | **Private Subnets** | Security First: ECS Tasks and RDS are protected from direct internet access. |
| **Automation** | **GitHub Actions** | Implements a controlled workflow (Test $\rightarrow$ Build $\rightarrow$ Deploy Staging $\rightarrow$ Manual Approval $\rightarrow$ Deploy Prod). |
| **Cost Control** | **No NAT Gateway** | Deliberately omitted the NAT Gateway for significant monthly cost savings. |

### 2.2 Security and Compliance Decisions

Security was enforced at the network level:

* **Network Isolation:** ECS Tasks and RDS run exclusively in **private subnets**.
* **Security Groups:** Enforce zero-trust rules: DB $\leftarrow$ ECS $\leftarrow$ ALB.
* **Secrets Management:** Credentials are stored securely in **GitHub Secrets** and **Terraform Variables** (not committed to Git).

### 2.3 Backup and Observability

* **Backup Strategy:** Fulfilled via **RDS Automated Backups**, providing daily snapshots and Point-in-Time Recovery (PITR).
* **Monitoring:** Used **AWS CloudWatch** for low-cost, native monitoring of ECS CPU/Memory, ALB requests, and RDS metrics.

---

## III. Issues Faced & How I Solved Them

This section details critical debugging and problem-solving actions taken during the deployment phase.

### 3.1 Containerization & Registry Access

| Issue | Cause | Resolution |
| :--- | :--- | :--- |
| **Docker $\rightarrow$ ECR Login Failure** | Incorrect or expired IAM credentials for the ECR authorization token. | **Regenerated IAM Access Keys** and used the PowerShell decoding method for a robust login command. |

### 3.2 ECS Deployment & Health Checks

| Issue | Cause | Resolution |
| :--- | :--- | :--- |
| **ECS Task Stuck in UNHEALTHY** | Port mismatch between the Container Port, Task Definition Port, and ALB Target Group Port. | **Standardized all three configurations to use Port 80** consistently across the deployment path. |
| **CloudFormation Error: ALB Exists** | An older, failed ECS console deployment left behind an orphaned CloudFormation stack managing the ALB resource. | **Manually deleted the specific, orphaned CloudFormation stack** (`ECS-Console-V2-Service-<name>`) via the AWS console. |

### 3.3 Infrastructure & Automation Debugging

| Issue | Cause | Resolution |
| :--- | :--- | :--- |
| **Terraform Remote State Conflicts** | Manual AWS resource creation (VPC, subnets) conflicted with Terraform's state file. | **Deleted conflicting manual resources** and established a unique naming prefix (`karan_`) for all IaC resources. |
| **CI/CD Error: Invalid Role** | The ECS Task Execution Role was missing required policies (e.g., to pull ECR images). | **Attached the `AmazonECSTaskExecutionRolePolicy`** to the Task Execution Role, granting necessary privileges. |

***

## Conclusion

The project successfully delivered a secure, cost-optimized, and fully automated backend solution on AWS. The challenges encountered validated a strong ability to debug complex issues related to networking, IAM, and container lifecycle management.