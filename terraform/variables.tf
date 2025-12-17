variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "multi-orchestrator-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}