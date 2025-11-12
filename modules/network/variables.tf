variable "name"           { type = string }
variable "vpc_cidr"       { type = string }
variable "azs"            { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "web_subnets"    { type = list(string) } # private
variable "app_subnets"    { type = list(string) } # intra(격리)
variable "db_subnets"     { type = list(string) }
variable "enable_nat_gateway" { type = bool }