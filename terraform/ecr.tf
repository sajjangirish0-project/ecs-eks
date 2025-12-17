module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  # Critical: Don't create repository since it already exists
  create_repository = false
  
  # Name of the EXISTING repository
  repository_name = "${var.project_name}-repository"
  repository_type = "private"

  # Only manage the lifecycle policy on the existing repository
  create_lifecycle_policy = true
  
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["latest"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project_name
  }
}