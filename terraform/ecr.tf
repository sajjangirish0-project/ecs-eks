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

# ECR Repository Policy for EKS access
resource "aws_ecr_repository_policy" "main" {
  repository = module.ecr.repository_name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSNodeAccess"
        Effect = "Allow"
        Principal = {
          AWS = module.eks.cluster_iam_role_arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}