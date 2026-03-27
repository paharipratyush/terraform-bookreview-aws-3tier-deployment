# 🚀 AWS 3-Tier Architecture Deployment with Terraform
![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

A fully automated, production-style 3-tier web application deployment on AWS using Modular Infrastructure-as-Code (IaC).  

This project provisions a secure, highly available environment for a **Next.js Frontend**, a **Node.js Backend**, and an **Amazon RDS MySQL Database**. It demonstrates Zero-Touch deployment, strict network isolation, Zero-Trust security group chaining, and automated instance bootstrapping.

---

## 🏗️ Architecture Overview

The infrastructure is engineered for security and scalability, completely isolating the backend and database from the public internet.

  <img width="801" height="941" alt="Untitled Diagram-Page-3 drawio" src="https://github.com/user-attachments/assets/4805980d-89b1-4544-8f93-634657ee6f71" />


- **Network Tier (VPC):**  

  A custom VPC (`10.0.0.0/16`) spanning 2 Availability Zones for high availability.  
  Contains 6 subnets:
  - 2 Public Web Subnets  
  - 2 Private App Subnets  
  - 2 Private DB Subnets  

- **Routing & NAT:**  
  - Public subnets route through an Internet Gateway (IGW)  
  - Private subnets access the internet securely via a NAT Gateway  

- **Security (Zero-Trust):**
  - **Public ALB:** Accepts HTTP traffic from `0.0.0.0/0`
  - **Web EC2s:** Only accept traffic from Public ALB
  - **Internal ALB:** Only accepts traffic from Web EC2s
  - **App EC2s:** Only accept traffic from Internal ALB
  - **RDS Database:** Only accepts MySQL traffic (Port 3306) from App EC2s  

- **Compute:**  
  Ubuntu 24.04 EC2 instances are automatically bootstrapped using `user_data` scripts to:
  - Install Node.js, PM2, and Nginx  
  - Clone application code  
  - Start backend and frontend services  

---

## 📂 Repository Structure

The Terraform code is modularized for reusability and clean state management.

```text
├── modules/
│   ├── compute/        # EC2 instances, Target Group Attachments
│   ├── database/       # RDS MySQL Instance, DB Subnet Group
│   ├── loadbalancing/  # Public/Internal ALBs, Target Groups, Listeners
│   ├── networking/     # VPC, Subnets, IGW, NAT, Route Tables
│   └── security/       # Tiered Security Groups
├── scripts/
│   ├── backend.sh.tpl  # Node.js backend bootstrapping & DB initialization
│   └── frontend.sh.tpl # Next.js frontend bootstrapping & Nginx Reverse Proxy
├── main.tf             # Root module connecting all components
├── variables.tf        # Global variables
├── outputs.tf          # Application URLs
└── providers.tf        # AWS provider configuration
```
## 🛠️ Prerequisites

Before you begin, ensure the following are installed and configured:

- **Terraform** (v1.0.0 or later)  
- **AWS CLI** (configured with an IAM user having Administrator access)  
- **AWS Key Pair**

   Terraform requires an existing SSH key pair to attach to the EC2 instances. You must create one in your target region (e.g., `ap-south-1`) before deploying.
     - **Option A (AWS CLI)**: Run this directly in your terminal:

       ```bash
       aws ec2 create-key-pair --region ap-south-1 --key-name dmi-key --query 'KeyMaterial' --output text > dmi-key.pem
       chmod 400 dmi-key.pem
       ```
     - **Option B (AWS Management Console)**: Manually create an RSA key pair named `dmi-key` via the AWS UI.
  
  (Note: If you choose a different name or region, ensure you update the `key_name` and `aws_region` variables in your `terraform.tfvars` file.)

---

## 🚀 Step-by-Step Deployment Guide

This project follows **secure secrets management** i.e., no passwords are stored in `.tfvars`.

### Step 1: Clone the Repository

```bash
git clone https://github.com/paharipratyush/terraform-bookreview-aws-3tier-deployment.git
cd terraform-bookreview-aws-3tier-deployment
```
### Step 2: Configure Safe Variables
Create a file named `terraform.tfvars` in the root directory. Add your non-sensitive configuration values here:
```Terraform
aws_region   = "ap-south-1"
project_name = "bookreview"
vpc_cidr     = "10.0.0.0/16"
key_name     = "dmi-key"
```
### Step 3: Initialize Terraform
Downloads the required AWS provider plugins and initializes the modules.
```bash
terraform init
```
### Step 4: Inject Secrets Securely
Export your desired RDS master password into your terminal session. Terraform automatically ingests environment variables prefixed with TF_VAR_.
```bash
export TF_VAR_db_password="YourSuperSecurePassword123!"
```
### Step 5: Review the Execution Plan
Verify the resources Terraform is about to create.
```bash
terraform plan
```
### Step 6: Deploy the Infrastructure
Verify the resources Terraform is about to create.
```bash
terraform apply --auto-approve
```
(Note: Deployment takes approximately 5-7 minutes, primarily due to the RDS database provisioning).
### Step 7: Access the Application
Upon completion, Terraform will output the `Book_Review_Live_URL` (your Public ALB DNS).
  - Wait an additional 3-4 minutes for the EC2 user_data bash scripts to finish installing Node.js, running the Next.js build, and starting the Nginx reverse proxy.
  - Navigate to the provided URL in your browser to interact with the live application.

## 🧹 Teardown & Cleanup

To avoid AWS charges, destroy all resources:

```bash
terraform destroy --auto-approve
```
✅ Ensure all resources are successfully deleted.

## ⚠️ Challenges & Fixes

- Encountered DB connection failures due to timing → solved using wait loop
- Faced permission issues → fixed using sudo -u ubuntu
- Backend not accessible → solved via internal ALB routing

## ⭐ Final Thoughts

 This project demonstrates real-world cloud engineering principles:

  - Modular Infrastructure Design
  - Zero-Trust Security
  - Automated Bootstrapping
  - Production-grade Networking

## 📌 Author

Built with 💻 by [Pratyush Pahari](https://github.com/paharipratyush)

Feel free to ⭐ the repo if you found it useful!
