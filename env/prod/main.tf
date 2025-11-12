module "network" {
  source = "../../modules/network"

  name              = var.name
  vpc_cidr          = var.vpc_cidr
  azs               = var.azs
  public_subnets    = var.public_subnets
  web_subnets       = var.web_subnets
  app_subnets       = var.app_subnets
  db_subnets        = var.db_subnets
  enable_nat_gateway= var.enable_nat_gateway
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
}