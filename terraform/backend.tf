terraform {
  backend "s3" {
    bucket         = "aws-terraform-state-bucket-eks"  # Replace with your bucket name
    key            = "multi-orchestrator/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}