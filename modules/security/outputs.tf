output "alb_public_sg_id" { value = aws_security_group.alb_public.id }
output "web_sg_id"        { value = aws_security_group.web.id }

output "app_alb_sg_id" { value = aws_security_group.app_alb_internal.id }
output "app_sg_id"     { value = aws_security_group.app.id }