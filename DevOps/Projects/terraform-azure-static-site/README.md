

# Azure Static Website with Terraform

Provision a cost-minimal **Azure Storage Static Website** inside an **existing Resource Group** using Terraform. Designed for RG-scope permissions (no subscription owner needed), with clean teardown.

> ✅ Tested with `azurerm v4.44.0` and the separate `azurerm_storage_account_static_website` resource.
> ✅ Output: the public web endpoint (e.g., `https://<account>.<zone>.web.core.windows.net/`)

---

## What this demonstrates

* Terraform workflow: **init → validate → plan → apply → destroy**
* AzureRM provider + **RG data source**, **module**, **variables/locals/outputs**
* Unique naming via **`random_string`**
* Static site enablement + upload of `index.html` / `404.html` to **`$web`**
* RG-only permissions: **`resource_provider_registrations = "none"`** in provider

---

## Architecture

```
Existing Resource Group (Experimental)
└─ Storage Account (Standard_LRS, StorageV2)
   ├─ Static website feature (enabled)
   └─ $web container
      ├─ index.html
      └─ 404.html
```

---

## Directory structure

```
terraform-azure-static-site/
├─ main.tf
├─ providers.tf
├─ variables.tf
├─ outputs.tf
├─ versions.tf
├─ modules/
│  └─ storage_static_site/
│     ├─ main.tf
│     ├─ variables.tf
│     └─ outputs.tf
└─ .gitignore
```

---

## Prerequisites

* **Azure CLI** logged in:

  ```bash
  az login
  az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
  ```
* **Terraform** ≥ 1.4.0
* You are **Owner** (or Contributor) on the **target Resource Group** (e.g., `Experimental`)
* Subscription admin has **Microsoft.Storage** RP registered (one-time):

  ```bash
  az provider show --namespace Microsoft.Storage --query registrationState -o tsv
  # If not 'Registered', a subscription Owner/Contributor must run:
  # az provider register --namespace Microsoft.Storage
  ```

> Because you only have RG-scope access, the provider is configured with
> `resource_provider_registrations = "none"` to avoid subscription-level registration attempts.

---

## Quickstart

```bash
terraform fmt -recursive
terraform init -upgrade
terraform validate

terraform plan \
  -var 'existing_rg_name=Experimental' \
  -var "subscription_id=$(az account show --query id -o tsv)"

terraform apply \
  -var 'existing_rg_name=Experimental' \
  -var "subscription_id=$(az account show --query id -o tsv)" \
  -auto-approve

terraform output static_site_url
```

You should see a URL like:

```
https://sttfstaticsiteXXXXXX.z13.web.core.windows.net/
```

---

## Variables

| Name                | Type   | Default                                     | Description                                                            |
| ------------------- | ------ | ------------------------------------------- | ---------------------------------------------------------------------- |
| `subscription_id`   | string | `null`                                      | Your Azure subscription ID (set via `-var` as shown above).            |
| `existing_rg_name`  | string | —                                           | **Existing** RG where you have Owner/Contributor (e.g., Experimental). |
| `project`           | string | `tfstaticsite`                              | Moniker used in resource names and tags.                               |
| `index_html`        | string | `<h1>Hello from Terraform on Azure 🎉</h1>` | Inline HTML content for demo homepage.                                 |
| `location_override` | string | `null`                                      | Override RG location; otherwise uses the RG’s own location.            |

---

## Outputs

| Name              | Description                           |
| ----------------- | ------------------------------------- |
| `static_site_url` | Public endpoint of the static website |

---

## How it works (files of interest)

* **`providers.tf`**
  Sets AzureRM provider with explicit `subscription_id` and
  `resource_provider_registrations = "none"` (RG-scope friendly).
* **`main.tf` (root)**
  Reads existing RG → calls child module.
* **`modules/storage_static_site/main.tf`**

  * `random_string` → unique SA name
  * `azurerm_storage_account` (StorageV2, LRS, TLS 1.2)
  * `azurerm_storage_account_static_website` → enables static site
  * Two `azurerm_storage_blob` resources upload `index.html` and `404.html` to **`$web`**
* **`outputs.tf` (root & module)**
  Exposes the storage account’s `primary_web_endpoint`.

---

## Security & cost notes

* `allow_nested_items_to_be_public = false` (best practice). Static website endpoint remains publicly readable.
* StorageV2 + LRS keeps cost minimal. Destroy when done.

---

## Cleanup

```bash
terraform destroy \
  -var 'existing_rg_name=Experimental' \
  -var "subscription_id=$(az account show --query id -o tsv)" \
  -auto-approve
```



