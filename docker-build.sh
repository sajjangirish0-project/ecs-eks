#!/bin/bash

# Script to build and push Docker image to ECR

set -e

AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REPO=${ECR_REPO}
IMAGE_TAG=${IMAGE_TAG:-latest}

if [ -z "$ECR_REPO" ]; then
    echo "Error: ECR_REPO environment variable is not set"
    exit 1
fi

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO

# Build the image
echo "Building Docker image..."
docker build -t multi-platform-app:latest ./app

# Tag the image
docker tag multi-platform-app:latest $ECR_REPO:$IMAGE_TAG

# Push the image
echo "Pushing image to ECR..."
docker push $ECR_REPO:$IMAGE_TAG

echo "Image pushed successfully: $ECR_REPO:$IMAGE_TAG"