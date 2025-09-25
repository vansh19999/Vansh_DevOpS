#!/usr/bin/env bash
set -euo pipefail
kubectl apply -f 00-namespace.yaml
kubectl apply -f 10-pod-multicontainer.yaml
kubectl apply -f 20-pod-a.yaml
kubectl apply -f 21-pod-b.yaml
kubectl apply -f 30-deploy-web.yaml
kubectl apply -f 31-svc-web-clusterip.yaml
# optional:
# kubectl apply -f 32-svc-web-nodeport.yaml
kubectl apply -f 33-svc-web-loadbalancer.yaml
echo "Waiting for deployment/web to be ready..."
kubectl -n netlab rollout status deploy/web
echo "Done. Use ./test_lab.sh to run quick checks."
