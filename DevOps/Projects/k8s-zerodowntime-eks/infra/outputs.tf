output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

output "nginx_lb_hostname" {
  description = "Public hostname of the ingress NLB/ALB once ready"
  value       = try(helm_release.ingress_nginx[0].status, null)
  depends_on  = [helm_release.ingress_nginx]
}

