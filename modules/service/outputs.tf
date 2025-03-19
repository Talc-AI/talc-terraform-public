output "deploy_tag" {
  value = var.deploy_tag
}

output "load_balancer_dns" {
  value = aws_lb.service.dns_name
}
