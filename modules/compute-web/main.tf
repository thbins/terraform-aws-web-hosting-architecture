# ALB
resource "aws_lb" "public" {
  name               = "alb-public"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [var.alb_sg_id]
  idle_timeout       = 60
}

resource "aws_lb_target_group" "web" {
  name_prefix = "tg-"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
    path     = "/"
    matcher  = "200-399"
    protocol = "HTTP"
  }
}

# (A) HTTP→TG (HTTPS 미사용 시만)
resource "aws_lb_listener" "http" {
  count             = var.enable_https ? 0 : 1
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# (B) HTTP→HTTPS 리다이렉트 (HTTPS 사용 시)
resource "aws_lb_listener" "http_redirect" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# (C) HTTPS 리스너
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# AMI: Amazon Linux 2023 (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter { 
    name="name" 
    values=["al2023-ami-*-x86_64"]
  }
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "lt-web-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name
  # vpc_security_group_ids = [var.web_sg_id] 
  user_data     = base64encode(var.user_data)

  network_interfaces {
    security_groups = [var.web_sg_id]
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-asg"
      Role = "web"
    }
  }
}

# ASG
resource "aws_autoscaling_group" "web" {
  name                      = "asg-web"
  desired_capacity          = var.desired
  min_size                  = var.min
  max_size                  = var.max
  vpc_zone_identifier       = var.instance_subnets
  health_check_type         = "ELB"
  health_check_grace_period = 90
  target_group_arns = [aws_lb_target_group.web.arn]

/*
  health_check_type = "EC2" -> "ELB" 로 변경
  target_group_arns = [aws_lb_target_group.web.arn] 추가 

	1.	앱 상태까지 감지
health_check_type="EC2"는 “인스턴스가 살아있나”만 봐요. NGINX가 죽었거나 SG/라우팅 때문에 LB에서 트래픽이 안 들어오면 EC2는 정상인데 서비스는 죽은 상태가 됩니다.
ELB로 바꾸면 타깃 그룹 헬스체크(HTTP 200~399) 기준으로 고장 감지 → 자동 교체가 정확해져요.
	2.	롤링 업데이트·스케일링이 안전
ASG가 타깃 그룹에 직접 연결(target_group_arns)되면 등록/해제, 드레이닝이 일관되게 처리돼서 5xx나 트래픽 홀(black hole) 위험이 줄어요.

이후

# ASG ↔ Target Group 연결
resource "aws_autoscaling_attachment" "tg" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}

위 리소스는 제거하였습니다.

*/
  

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # 다운타임 최소화
  lifecycle { create_before_destroy = true }

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }
}