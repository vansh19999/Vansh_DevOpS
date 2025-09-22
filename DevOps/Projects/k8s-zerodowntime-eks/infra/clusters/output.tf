output "region" {
  value       = var.region
  description = "AWS region"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "ecr_repo_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "ECR repository URL"
}
