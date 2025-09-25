#!/usr/bin/env bash
set -euo pipefail
echo "[1] container<->container (localhost):"
kubectl -n netlab exec -it sidecar-demo -c helper -- sh -lc 'curl -s localhost:8080 || true'

echo -e "\n[2] pod<->pod by IP:"
B_IP=$(kubectl -n netlab get pod testpod-b -o jsonpath='{.status.podIP}')
echo "B_IP=$B_IP"
kubectl -n netlab exec -it testpod-a -- sh -lc "curl -s http://$B_IP:8080 || true"

echo -e "\n[3] pod<->Service (DNS + LB):"
for i in $(seq 1 5); do
  kubectl -n netlab exec -it testpod-a -- sh -lc 'curl -s http://web.netlab.svc.cluster.local/ | head -n 2'
  sleep 1
done

echo -e "\n[4] external<->Service (LoadBalancer):"
kubectl -n netlab get svc web-public -o wide
echo "When EXTERNAL-IP is ready, curl it from your machine:  curl -s http://<EXTERNAL-IP>/"
