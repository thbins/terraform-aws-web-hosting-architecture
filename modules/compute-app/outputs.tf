output "alb_dns" {
  value = aws_lb.internal_app.dns_name
}