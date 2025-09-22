# Zero-Downtime Releases on Kubernetes (EKS)

## Run
1) Cluster:
   cd infra/cluster && terraform init && terraform apply
   CLUSTER_NAME=$(terraform output -raw cluster_name)
   REGION=$(terraform output -raw region 2>/dev/null || echo us-east-1)
   aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION" --profile terraform-admi
   kubectl get nodes

2) Addons (ingress):
   cd ../addons && terraform init && terraform apply -var="region=$REGION" -var="cluster_name=$CLUSTER_NAME"
   kubectl get svc -n ingress-nginx

3) App:
   Build & push to ECR (from infra/cluster output), update k8s image refs, then:
   kubectl apply -f k8s/
