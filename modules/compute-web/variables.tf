variable "vpc_id"           { type = string }
variable "alb_subnets"      { type = list(string) }  # 퍼블릭 서브넷
variable "instance_subnets" { type = list(string) }  # (지금은 퍼블릭; 이후 web 서브넷으로 변경)
variable "alb_sg_id"        { type = string }
variable "web_sg_id"        { type = string }
variable "key_name"         { type = string }
variable "instance_type"    { 
                                type = string  
                                default = "t2.micro"
                            }
variable "desired"          { 
                              type = number
                              default = 2 
                            }
variable "min"              { 
                              type = number  
                              default = 2
                            }
variable "max"              { 
                              type = number
                              default = 4 
                            }

variable "enable_https"    { 
  type = bool   
  default = false # 나중에 HTTPS 활성화할 경우, true로 변경
}
variable "certificate_arn" { type = string }  # ap-northeast-2 ACM ARN
variable "ssl_policy"      { 
  type = string 
  default = "ELBSecurityPolicy-2016-08"
}

variable "user_data" {
  type    = string
  default = <<-EOF
  #!/bin/bash
  dnf -y install nginx
  echo "Hello from WEB $(hostname -f)" > /usr/share/nginx/html/index.html
  systemctl enable --now nginx
  EOF
}