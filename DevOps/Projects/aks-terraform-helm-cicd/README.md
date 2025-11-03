# aks-terraform-helm-cicd (cost-friendly)

## Quick start
1) Ensure you have Owner on RG `devops.experiment`.
2) In Azure DevOps, create a service connection named **azure-oidc-conn** (OIDC, no secrets).
3) Run the **infra** pipeline to create AKS + ACR + Log Analytics.
4) Capture output **ACR login server** and set ACR_NAME pipeline variable.
5) Update `app/charts/app/values.yaml` `image.repository` to `<acr>.azurecr.io/orders-api` (script does this in deploy).
6) Run **app** pipeline to build/push the image and deploy with Helm.

### Local (optional)
```bash
cd infra && terraform init && terraform apply
az aks get-credentials -g devops.experiment -n aks-demo --overwrite-existing
helm upgrade --install orders app/charts/app -n orders --create-namespace

