# GitOps Platform (Monorepo) — AKS + Argo CD + Argo Rollouts

This monorepo installs **Argo CD** on an existing Kubernetes cluster (AKS recommended)
using Terraform, then bootstraps the **App-of-Apps** pattern so Argo CD manages:
- Platform add-ons (Ingress NGINX, cert-manager, Argo Rollouts)
- Your application charts housed under ./apps/

## Quick start
1) Point kubeconfig to your AKS:
   az login
   az account set --subscription "<SUB_ID>"
   az aks get-credentials -g <RG> -n <AKS_NAME> --overwrite-existing

2) Deploy Argo CD:
   cd infra
   terraform init
   terraform plan  -var-file=envs/dev.tfvars
   terraform apply -var-file=envs/dev.tfvars -auto-approve

3) Apply AppProjects (RBAC boundaries) first:
   kubectl apply -n argocd -f platform/projects/

4) Bootstrap root "App-of-Apps" (children = platform add-ons + app):
   kubectl apply -n argocd -f platform/argocd/bootstrap/root-app.yaml

5) Get Argo CD server address (Service is LoadBalancer by default):
   kubectl get svc -n argocd

Initial admin password:
   kubectl -n argocd get secret argocd-initial-admin-secret \
     -o jsonpath='{.data.password}' | base64 -d && echo

## Where things live
- infra/                        # Terraform: Argo CD install via Helm provider
- platform/argocd/bootstrap/    # Root Application (App-of-Apps)
- platform/projects/            # Argo CD AppProjects (policy boundaries)
- platform/apps/                # Argo CD Applications for platform + app
- apps/services/hello/charts/   # Sample app Helm chart using Argo Rollouts

## Notes
- For learning, Argo CD server is a LoadBalancer and runs insecure HTTP.
  In production: use Ingress + TLS + SSO (OIDC), RBAC hardening, NetworkPolicies.
- Canary is powered by **Argo Rollouts**. Your Ingress routes to the stable Service;
  Rollouts gradually shifts traffic to the canary Service during deployment.
