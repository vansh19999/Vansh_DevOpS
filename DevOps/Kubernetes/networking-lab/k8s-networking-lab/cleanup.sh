#!/usr/bin/env bash
set -euo pipefail
kubectl delete ns netlab --wait=true || true
echo "Namespace deleted. If you created an EKS test cluster with eksctl, delete it with:"
echo "eksctl delete cluster --name netlab-eks --region \$AWS_REGION --profile \$AWS_PROFILE"
