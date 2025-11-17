# Internal ALB (App)
resource "aws_lb" "internal_app" {
  name               = "alb-internal-app"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [var.app_alb_sg_id]
  idle_timeout       = 60
}

resource "aws_lb_target_group" "app" {
  name_prefix = "tgapp-"     # ≤ 6자 제약
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path    = "/"
    matcher = "200-399"
    port    = "traffic-port"
  }

  deregistration_delay = 30
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal_app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# AMI: Amazon Linux 2023 (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name" values = ["al2023-ami-*-x86_64"] }
}

# Launch Template (App)
resource "aws_launch_template" "app" {
  name_prefix   = "lt-app-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(var.user_data)

  network_interfaces {
    security_groups             = [var.app_sg_id]
    associate_public_ip_address = false
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"   # IMDSv2 강제
  }

  monitoring { enabled = true }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "app-asg", Role = "app" }
  }
}

# ASG (App)
resource "aws_autoscaling_group" "app" {
  name                = "asg-app"
  desired_capacity    = var.desired
  min_size            = var.min
  max_size            = var.max
  vpc_zone_identifier = var.instance_subnets

  health_check_type         = "ELB"
  health_check_grace_period = 90
  target_group_arns         = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  lifecycle { create_before_destroy = true }

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = true
  }
}