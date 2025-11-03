# AWS Provider block for Terraform
provider "aws" {
    region  = var.region      # AWS region to deploy resources (e.g., us-west-2)
    profile = var.aws_profile != "" ? var.aws_profile : null  # AWS CLI profile to use for authentication, if specified
}

# --- Keyword Explanations ---

# provider "aws": Specifies the AWS cloud provider for Terraform to manage resources.
# region: The geographical AWS region where resources will be created (e.g., us-east-1, eu-central-1).
# profile: The named AWS CLI profile for credentials; allows switching between different AWS accounts.
# var.region: A Terraform variable holding the AWS region value.
# var.aws_profile: A Terraform variable holding the AWS profile name.
# null: Indicates no profile is set; Terraform will use default credentials.

# --- Kubernetes Related Keywords (for context) ---

# Kubernetes: An open-source platform for automating deployment, scaling, and management of containerized applications.
# EKS (Elastic Kubernetes Service): AWS managed Kubernetes service for running Kubernetes clusters.
# Helm: A package manager for Kubernetes, used to deploy applications as charts.
