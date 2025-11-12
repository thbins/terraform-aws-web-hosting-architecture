output "vpc_id"            { value = module.network.vpc_id }
output "public_subnet_ids" { value = module.network.public_subnet_ids }
output "web_subnet_ids"    { value = module.network.web_subnet_ids }
output "app_subnet_ids"    { value = module.network.app_subnet_ids }
output "db_subnet_ids"     { value = module.network.db_subnet_ids }
output "compute_web_alb_dns" { value = module.compute_web.alb_dns }