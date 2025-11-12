locals {
  public_ids = [for k in sort(keys(aws_subnet.public_subnet)) : aws_subnet.public_subnet[k].id]
  web_ids    = [for k in sort(keys(aws_subnet.web_subnet))    : aws_subnet.web_subnet[k].id]
  app_ids    = [for k in sort(keys(aws_subnet.app_subnet))    : aws_subnet.app_subnet[k].id]
  db_ids     = [for k in sort(keys(aws_subnet.db_subnet))     : aws_subnet.db_subnet[k].id]
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = local.public_ids
}

output "web_subnet_ids" {
  value = local.web_ids
}

output "app_subnet_ids" {
  value = local.app_ids
}

output "db_subnet_ids" {
  value = local.db_ids
}