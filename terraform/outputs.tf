# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "ecs_alb_dns_name" {
  description = "DNS name of the ECS Application Load Balancer"
  value       = aws_lb.ecs.dns_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

# EKS Outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# Combined Service URLs
output "ecs_service_url" {
  description = "Full URL to access ECS service"
  value       = "http://${aws_lb.ecs.dns_name}:8080"
}

# Comment out or simplify EKS service URL until it's properly defined
# output "eks_service_url" {
#   description = "Full URL to access EKS service"
#   value       = "Pending - will be available after deployment"
# }