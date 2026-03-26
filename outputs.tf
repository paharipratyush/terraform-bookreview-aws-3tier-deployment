output "Book_Review_Live_URL" {
  description = "Paste this URL into your browser to access the live Next.js frontend!"
  value       = "http://${module.loadbalancing.public_alb_dns}"
}

output "Internal_ALB_DNS" {
  description = "The internal DNS routing traffic to the Node.js backend"
  value       = module.loadbalancing.internal_alb_dns
}
