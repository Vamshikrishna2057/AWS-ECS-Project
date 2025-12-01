🚀 Secure 3-Tier AWS ECS Application with Terraform

Author: Vamshikrishna Kalakonda

1. 📌 Project Overview

This project provisions a secure 3-tier web application on AWS using:

ECS Fargate (frontend + backend containers)

PostgreSQL on RDS (private subnets)

Application Load Balancer (public)

Secrets Manager for DB credentials

CloudWatch Logs & Alarms

S3 + DynamoDB for remote Terraform state

VPC with public/private subnets, NAT, routing

Application Layers:

Layer	Technology	Description
Frontend	ECS Fargate	Web UI (port 80)
Backend	ECS Fargate	Node.js API (port 3000)
Database	RDS PostgreSQL	Private DB used by API

Infrastructure is fully automated with Terraform modules.

2. 📁 Repository Structure
AWS-ECS-Terraform/
├── modules/
│   ├── vpc
│   ├── security-groups
│   ├── rds
│   ├── secrets
│   ├── ecr
│   ├── iam
│   ├── logs
│   ├── ecs
│   ├── ecs-task
│   ├── ecs-services
│   ├── alb
│   ├── cloudwatch
└── environments/
    └── Dev/
        ├── main.tf
        ├── backend.tf
        ├── variables.tf
        ├── terraform.tfvars
        └── provider.tf


Deploy using:

cd environments/Dev
terraform init
terraform plan
terraform apply -auto-approve

3. 🏗 Architecture & Traffic Flow
3.1 High-Level Flow

User hits ALB HTTP/HTTPS endpoint

ALB forwards:

/ → frontend ECS service

/api/* → backend ECS service

Backend fetches DB credentials from Secrets Manager

Backend connects to PostgreSQL inside private subnets

All logs go to CloudWatch Logs

CloudWatch Alarms → ECS auto-scaling

4. 🐳 Containerization (Docker)
Docker images

frontend-latest

backend-latest

Build commands:
docker build -t frontend-latest ./frontend
docker build -t backend-latest ./backend

Push to ECR:
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com

docker tag frontend-latest <ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/vamshi-kalakonda-ecs-app:frontend-latest
docker tag backend-latest  <ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/vamshi-kalakonda-ecs-app:backend-latest

docker push <ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/vamshi-kalakonda-ecs-app:frontend-latest
docker push <ACCOUNT>.dkr.ecr.us-east-1.amazonaws.com/vamshi-kalakonda-ecs-app:backend-latest

5. ☁ Terraform Remote State (S3 + DynamoDB)
S3 bucket:
aws s3api create-bucket --bucket vamshi-ecs-terraform-state --region us-east-1

DynamoDB table:
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

Backend (backend.tf):

bucket = "vamshi-ecs-terraform-state"

key = "dev/terraform.tfstate"

dynamodb_table = "terraform-locks"

6. 🧱 Module-by-Module Terraform Implementation
✔ VPC

1 VPC (10.0.0.0/16)

2 public + 2 private subnets

IGW + NAT Gateway

Public/private route tables

✔ Security Groups

ALB SG: inbound 80/443

ECS SG: inbound 80/3000 from ALB

RDS SG: inbound 5432 from ECS only

✔ RDS PostgreSQL

Engine: Postgres 15

DB subnet group (private subnets)

Security: restricted to ECS only

Fixed SSL / pg_hba.conf issues with parameter group

✔ Secrets Manager

Stores:

username

password

db_host

db_port

db_name

Used by backend ECS task.

✔ IAM

ECS task execution role

ECS task role (secretsmanager:GetSecretValue)

✔ Logs

/ecs/frontend

/ecs/backend

✔ ECS Cluster

Provisioned Fargate cluster for the services.

✔ ECS Task Definitions

Frontend: container port 80

Backend: container port 3000

Backend loads DB credentials from Secrets Manager

✔ ALB

Listener: port 80

Target Groups:

Frontend TG → port 80

Backend TG → port 3000

✔ ECS Services

Fargate launch type

Private subnets

Service discovery for backend (Cloud Map)

✔ Auto Scaling

CPU-based ECS target tracking policies.

7. 🧪 End-to-End Deployment Flow
cd environments/Dev
terraform init
terraform plan
terraform apply -auto-approve

Debug logs:
aws logs tail /ecs/backend --since 10m --follow
aws logs tail /ecs/frontend --since 10m --follow

Force ECS deployment:
aws ecs update-service \
  --cluster vamshi-ecs-app-ecs-cluster \
  --service vamshi-ecs-app-backend-service \
  --force-new-deployment

8. 🌐 Application URLs

If deployed with domain:

Frontend: http://your-domain.com

Backend API: http://your-domain.com/api/*

9. 🙌 Conclusion

This project demonstrates:

✔ Complete AWS ECS microservices deployment
✔ Fully modular Terraform
✔ Secure DB access with Secrets Manager
✔ End-to-end CI-ready container workflow
✔ Scalable, production-grade AWS setup