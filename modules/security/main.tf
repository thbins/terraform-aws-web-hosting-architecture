# 퍼블릭 ALB SG (HTTP 80 오픈)
resource "aws_security_group" "alb_public" {
  name   = "alb-public-sg"
  vpc_id = var.vpc_id
  egress { 
    from_port=0 
    to_port=0 
    protocol="-1" 
    cidr_blocks=["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb80" {
  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Web 인스턴스 SG (ALB에서만 80 허용)
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = var.vpc_id
  egress { 
    from_port=0 
    to_port=0 
    protocol="-1" 
    cidr_blocks=["0.0.0.0/0"]
  }

}
resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb_public.id
  ip_protocol = "tcp"
  from_port  = 80
  to_port    = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb443" {
  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}