# 공통
variable "env"    { type = string }
variable "region" { type = string }
variable "name"   { type = string }

# 네트워크
variable "azs"            { type = list(string) }
variable "vpc_cidr"       { type = string }
variable "public_subnets" { type = list(string) }
variable "web_subnets"    { type = list(string) }
variable "app_subnets"    { type = list(string) }
variable "db_subnets"     { type = list(string) }

# 비용 때문에 처음엔 NAT을 꺼둘 수 있게 스위치 추가(추후 켤 수 있음)
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "key_name" { type = string }