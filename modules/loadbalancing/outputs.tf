# The DNS names must be exported so we can inject them into our EC2 .env files
output "public_alb_dns" {
  value = aws_lb.public_alb.dns_name
}

output "internal_alb_dns" {
  value = aws_lb.internal_alb.dns_name
}

# The Target Group ARNs must be exported so the EC2 instances can attach to them
output "web_tg_arn" {
  value = aws_lb_target_group.web_tg.arn
}

output "app_tg_arn" {
  value = aws_lb_target_group.app_tg.arn
}
