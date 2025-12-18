# Multi-Orchestrator Application Deployment (ECS & EKS)

## Hands-On Task Overview

This project demonstrates **deploying the same containerized application to both Amazon ECS (Fargate) and Amazon EKS (Kubernetes)** using a single Docker image stored in **Amazon ECR**.

The goal is to:

* Understand the deployment workflow for ECS and EKS
* Compare operational complexity, scaling, and use cases
* Learn when to choose ECS vs EKS in real-world architectures

---

## Architecture Overview

```
┌──────────────┐        ┌──────────────┐
│   Amazon     │        │   Amazon     │
│     ECR      │<──────▶│  Docker CLI  │
└──────────────┘        └──────────────┘
        │
        │ Same Image
        ▼
┌───────────────────────┐     ┌────────────────────────┐
│        ECS (Fargate)  │     │        EKS (Kubernetes) │
│  - Task Definition    │     │  - Deployment           │
│  - ECS Service        │     │  - Service (LB)         │
│  - ALB                │     │  - Pods                 │
└───────────────────────┘     └────────────────────────┘
```

---

## Prerequisites

* AWS Account with required IAM permissions
* Basic knowledge of Docker & containers
* AWS CLI installed and configured
* Docker installed
* kubectl installed (for EKS)

---

## Phase 1: Container Setup (ECR)

### Step 1: Create a Simple Web Application

**app.py**

```python
from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Container!',
        'hostname': socket.gethostname(),
        'platform': os.environ.get('PLATFORM', 'Unknown')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
```

**requirements.txt**

```txt
Flask==2.3.3
```

---

### Step 2: Create Dockerfile

```dockerfile
FROM python:3.9-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

ENV PLATFORM=Docker
EXPOSE 8080

CMD ["python", "app.py"]
```

---

### Step 3: Create ECR Repository

**AWS Console**

1. Go to **ECR → Repositories → Create repository**
2. Visibility: Private
3. Name: `multi-platform-app`

**AWS CLI**

```bash
aws ecr create-repository --repository-name multi-platform-app
```

---

### Step 4: Build and Push Image

```bash
# Build image
docker build -t multi-platform-app .

# Tag image
docker tag multi-platform-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/multi-platform-app:latest

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Push image
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/multi-platform-app:latest
```

---

## Phase 2: Deploy to ECS (Fargate)

### Step 5: Create ECS Cluster

* Cluster name: `ecs-demo-cluster`
* Infrastructure: **AWS Fargate (Serverless)**

---

### Step 6: Create Task Definition

* Task Name: `multi-platform-task`
* CPU: `0.25 vCPU`
* Memory: `0.5 GB`
* Container:

  * Name: `web-app`
  * Image: ECR image URI
  * Port: `8080`
  * Env Variable:

    * `PLATFORM=ECS-Fargate`

---

### Step 7: Create ECS Service

* Service name: `ecs-web-service`
* Desired tasks: `2`
* Networking:

  * Default VPC
  * 2+ subnets
  * Security Group: Allow port `8080`
* Load Balancer: **Application Load Balancer**

---

### Step 8: Test ECS Deployment

Access via ALB DNS:

```
http://<ALB-DNS>:8080
```

Expected response:

```json
{
  "message": "Hello from Container!",
  "hostname": "ip-10-0-1-5.ec2.internal",
  "platform": "ECS-Fargate"
}
```

---

## Phase 3: Deploy to EKS (Kubernetes)

### Step 9: Create EKS Cluster

* Cluster name: `eks-demo-cluster`
* Kubernetes version: Latest stable
* Networking: Default VPC + private subnets

**CLI Example**

```bash
aws eks create-cluster \
  --name eks-demo-cluster \
  --version 1.28 \
  --role-arn arn:aws:iam::123456789012:role/eks-service-role \
  --resources-vpc-config subnetIds=subnet-12345,subnet-67890

aws eks wait cluster-active --name eks-demo-cluster
aws eks update-kubeconfig --region us-east-1 --name eks-demo-cluster
```

---

### Step 10: Kubernetes Deployment & Service

**eks-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/multi-platform-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: PLATFORM
          value: "EKS-Kubernetes"
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
```

---

### Step 11: Deploy to EKS

```bash
kubectl apply -f eks-deployment.yaml
kubectl get deployments
kubectl get pods
kubectl get services

kubectl get service web-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

---

### Step 12: Test EKS Deployment

```
http://<ELB-URL>
```

Expected response:

```json
{
  "message": "Hello from Container!",
  "hostname": "web-app-7c8b5d6f9-abc123",
  "platform": "EKS-Kubernetes"
}
```

---

## Phase 4: Comparison & Analysis

| Aspect        | ECS (Fargate)    | EKS (Kubernetes)      |
| ------------- | ---------------- | --------------------- |
| Setup Time    | 5–10 mins        | 15–30 mins            |
| Complexity    | Simple           | High                  |
| K8s Knowledge | Not required     | Required              |
| Load Balancer | Automatic        | Manual (Service)      |
| Scaling       | ECS Auto Scaling | HPA / Autoscaler      |
| Cost Model    | Pay per task     | Nodes + control plane |

---

## Phase 5: Scaling

### ECS Scaling

* Min tasks: 2
* Max tasks: 5
* Target CPU: 70%

### EKS Scaling

```bash
kubectl scale deployment/web-app --replicas=3
kubectl get pods
```

---


<img width="966" height="277" alt="Screenshot 2025-12-17 at 11 22 07 PM" src="https://github.com/user-attachments/assets/fed04970-6e3c-4468-8fe4-5a0ee3985bb5" />

<img width="886" height="454" alt="Screenshot 2025-12-18 at 12 07 36 AM" src="https://github.com/user-attachments/assets/c0dd9282-e5fd-4c96-984c-c032b44ae249" />



## Cleanup

### ECS Cleanup

* Delete ECS Cluster
* Deregister task definitions
* Delete ALB

### EKS Cleanup

```bash
kubectl delete -f eks-deployment.yaml
aws eks delete-cluster --name eks-demo-cluster
```

### ECR Cleanup

* Delete ECR repository

---

## Success Criteria

* Same Docker image runs on ECS and EKS
* Accessible via Load Balancers
* Correct platform identifier returned
* Able to scale both deployments
* Clear understanding of ECS vs EKS

---

## Estimated Time

* **Total:** 2–3 hours
* ECR: 15 mins
* ECS: 30–45 mins
* EKS: 45–60 mins
* Testing & comparison: 30 mins

---

## Key Takeaway

✅ **Use ECS (Fargate)** for simplicity, faster delivery, and minimal ops

✅ **Use EKS** when Kubernetes portability, ecosystem, and fine-grained control are required

---

Happy Learning 🚀
