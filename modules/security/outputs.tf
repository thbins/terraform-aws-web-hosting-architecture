output "alb_public_sg_id" { value = aws_security_group.alb_public.id }
output "web_sg_id"        { value = aws_security_group.web.id }