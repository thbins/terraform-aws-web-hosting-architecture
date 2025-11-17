variable "vpc_id"            { type = string }
variable "alb_subnets"       { type = list(string) }   # App ALB가 들어갈 app 서브넷
variable "instance_subnets"  { type = list(string) }   # App ASG 인스턴스 서브넷(=app)
variable "app_alb_sg_id"     { type = string }
variable "app_sg_id"         { type = string }
variable "key_name"          { type = string }
variable "instance_type"     { type = string  default = "t3.micro" }
variable "desired"           { type = number  default = 2 }
variable "min"               { type = number  default = 2 }
variable "max"               { type = number  default = 4 }

variable "user_data" {
  type    = string
  default = <<-EOF
  #!/bin/bash
  set -eux
  sleep 10
  dnf -y makecache
  dnf -y install nginx
  # NGINX를 8080 포트로 서비스
  sed -i 's/listen       80;/listen       8080;/' /etc/nginx/nginx.conf
  echo "Hello from APP $(hostname -f)" > /usr/share/nginx/html/index.html
  systemctl enable --now nginx
  EOF
}