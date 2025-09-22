output "ingress_release_status" {
  value       = helm_release.ingress_nginx.status
  description = "Helm release status of ingress-nginx"
}
