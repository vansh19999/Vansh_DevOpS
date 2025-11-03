// This Terraform file defines outputs for an EKS (Elastic Kubernetes Service) cluster.
// Outputs make important resource attributes available after deployment, such as cluster name, endpoint, and region.

output "cluster_name" {
  value = module.eks.cluster_name        // The name of the EKS cluster.
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint    // The API server endpoint for the EKS cluster.
}

output "cluster_certificate_authority_data" {
  value     = module.eks.cluster_certificate_authority_data // CA data for secure communication with the cluster.
  sensitive = true                                         // Marks this output as sensitive to hide it in logs.
}

output "region" {
  value = var.region                     // The AWS region where the EKS cluster is deployed.
}

# --- Terraform & AWS Keywords Explanation ---

# output: Declares an output variable to expose resource attributes after deployment.
# value: The actual value to output, often referencing a resource or module attribute.
# sensitive: If true, hides the output value from CLI output and logs for security.
# module.eks: Refers to the EKS module, which provisions the Kubernetes cluster on AWS.
# cluster_name: The name assigned to the EKS cluster.
# cluster_endpoint: The URL endpoint for the Kubernetes API server.
# cluster_certificate_authority_data: Certificate Authority data for secure cluster access.
# var.region: The AWS region variable, specifying where resources are created.

# --- Kubernetes Keywords Explanation ---

# cluster_name: The name of the Kubernetes cluster.
# cluster_endpoint: The API server endpoint used to interact with the Kubernetes cluster.
# cluster_certificate_authority_data: CA data required for secure communication with the Kubernetes API server.