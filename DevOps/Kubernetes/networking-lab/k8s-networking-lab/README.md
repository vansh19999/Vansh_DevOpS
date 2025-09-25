
## Quick write (copies the README into your lab dir)

````bash
LABDIR="$HOME/k8s-networking-lab"   # change if your folder lives elsewhere
mkdir -p "$LABDIR"
cat > "$LABDIR/README.md" <<'EOF'
# Kubernetes Networking Lab on EKS

This lab demonstrates the 4 core networking paths in Kubernetes on a fresh EKS cluster:

1) Container ↔ Container (same Pod / localhost)  
2) Pod ↔ Pod (cluster networking, Pod IP)  
3) Pod ↔ Service (stable VIP & DNS + load balancing)  
4) External ↔ Service (cloud LoadBalancer)

---

## Prerequisites

- AWS account + IAM user with EKS/EC2/IAM/CFN permissions  
- CLI tools: `awscli`, `kubectl`, `eksctl`
- Set your AWS identity:
```bash
export AWS_PROFILE=terraform-admi
export AWS_REGION=us-east-1
````

## Create a tiny EKS cluster (clean and isolated)

```bash
eksctl create cluster \
  --name netlab-eks \
  --region "$AWS_REGION" \
  --version 1.30 \
  --nodes 2 \
  --node-type t3.small \
  --managed \
  --profile "$AWS_PROFILE"

# configure kubectl for the new cluster
aws eks update-kubeconfig --name netlab-eks --region "$AWS_REGION" --profile "$AWS_PROFILE"
kubectl config use-context "$(kubectl config get-contexts -o name | grep netlab-eks)"
kubectl get nodes -o wide
```

---

## Apply manifests

Run from this folder:

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 10-pod-multicontainer.yaml
kubectl apply -f 20-pod-a.yaml
kubectl apply -f 21-pod-b.yaml
kubectl apply -f 30-deploy-web.yaml
kubectl apply -f 31-svc-web-clusterip.yaml
kubectl apply -f 33-svc-web-loadbalancer.yaml   # external access
kubectl -n netlab rollout status deploy/web
```

---

## Tests

### 1) Container ↔ Container (same Pod / localhost)

```bash
# From helper container, curl the api container via localhost:8080
kubectl -n netlab exec -it sidecar-demo -c helper -- sh -lc 'curl -s localhost:8080'
# Expected: hello-from-api
```

### 2) Pod ↔ Pod by IP (cluster networking)

```bash
# Get Pod IP for testpod-b
B_IP=$(kubectl -n netlab get pod testpod-b -o jsonpath='{.status.podIP}')
echo "B_IP=$B_IP"

# From testpod-a, curl testpod-b by its Pod IP
kubectl -n netlab exec -it testpod-a -- sh -lc "curl -s http://$B_IP:8080"
# Expected: hello-from-B
```

### 3) Pod ↔ Service (stable VIP & DNS + load balancing)

```bash
# Call the ClusterIP Service by DNS and watch responses alternate between pods
for i in $(seq 1 5); do
  kubectl -n netlab exec -it testpod-a -- sh -lc 'curl -s http://web.netlab.svc.cluster.local/ | head -n 2'
  sleep 1
done
```

### 4) External ↔ Service (cloud LoadBalancer)

```bash
# Get the external address (may take 1–3 minutes to appear)
kubectl -n netlab get svc web-public -w
# Then from your machine (not inside a pod):
curl -s http://<EXTERNAL-IP>/
```

---

## (Optional) NodePort example

```bash
kubectl -n netlab apply -f 32-svc-web-nodeport.yaml
kubectl -n netlab get svc web-nodeport -o wide
# Then (inside VPC / or if nodes have public IPs):
curl -s http://<any-node-external-ip>:30080
```

---

## Useful inspections

```bash
# Pod IPs and nodes
kubectl -n netlab get pods -o wide

# Service details and endpoints
kubectl -n netlab get svc web -o wide
kubectl -n netlab get endpoints web -o wide

# Describe for troubleshooting
kubectl -n netlab describe svc web-public
kubectl -n netlab describe pod testpod-a
```

---

## Cleanup

```bash
# Remove lab workloads
kubectl delete ns netlab --wait=true

# Remove the entire EKS cluster (if it was created just for this lab)
eksctl delete cluster --name netlab-eks --region "$AWS_REGION" --profile "$AWS_PROFILE"
```

---

## What you should learn

* **IP-per-Pod**: containers in one Pod share the same network namespace → `localhost` works across them.
* **Pod IPs are ephemeral**: don’t hardcode; use a **Service** for stability.
* **Service (ClusterIP)** provides stable VIP/DNS and load balancing to ready Pods.
* **LoadBalancer** Service publishes your app externally via a cloud LB.



```

If your lab lives somewhere else (e.g., `/Users/vansh/Vansh_DevOpS/DevOps/Projects/k8s-networking-lab`), just set `LABDIR` to that path before running the command.
```
