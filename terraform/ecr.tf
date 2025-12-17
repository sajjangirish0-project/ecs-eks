module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name = "${var.project_name}-repository"
  repository_type = "private"

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