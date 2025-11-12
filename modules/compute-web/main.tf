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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"
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
  health_check_type         = "EC2"
  health_check_grace_period = 60

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

# ASG ↔ Target Group 연결
resource "aws_autoscaling_attachment" "tg" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}