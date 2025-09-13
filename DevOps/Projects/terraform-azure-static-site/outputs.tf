output "static_site_url" {
  description = "Public URL of the static website."
  value       = module.static_site.primary_web_endpoint
}
