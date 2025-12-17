# eks.tf - Update the EKS module configuration

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-eks-cluster"
  cluster_version = "1.29"

  # Explicitly set IAM role names to avoid length issues
  iam_role_name = "${var.project_name}-eks-role"
  
  # Prevent the module from adding prefixes
  iam_role_use_name_prefix = false
  
  # Create a custom IAM role instead of using the module's default
  create_iam_role = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Enable EKS control plane logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # EKS Managed Node Group - Keep this configuration
  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"

      tags = {
        Environment = var.environment
        Project     = var.project_name
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}