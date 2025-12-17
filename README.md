# Multi-Orchestrator Application Deployment

This project demonstrates deploying the same containerized application to both AWS ECS and EKS using Terraform and GitHub Actions.

## Architecture

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **GitHub Repository** with the following secrets:
   - `AWS_ROLE_ARN`: ARN of IAM Role for GitHub Actions
   - `TF_STATE_BUCKET`: S3 bucket for Terraform state
   - `ECR_REPOSITORY`: ECR repository URL (will be created by Terraform)

3. **Local Requirements** (for manual deployment):
   - Terraform >= 1.0
   - AWS CLI
   - Docker
   - kubectl

## Setup Instructions

### 1. Initial AWS Setup

Create IAM Role for GitHub Actions:
```bash
# Create IAM role with necessary permissions
# (Policy JSON available in iam-policy.json)

aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-east-1 \
  --create-bucket-configuration LocationConstraint=us-east-1