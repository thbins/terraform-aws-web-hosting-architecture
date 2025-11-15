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

module "compute_web" {
  source            = "../../modules/compute-web"
  vpc_id            = module.network.vpc_id
  alb_subnets       = module.network.public_subnet_ids
  instance_subnets  = module.network.web_subnet_ids   # ▶ NAT OFF 상태: 퍼블릭 서브넷에서 테스트 후, NAT ON으로 변경함.
  alb_sg_id         = module.security.alb_public_sg_id
  web_sg_id         = module.security.web_sg_id
  key_name          = var.key_name
  enable_https    = var.enable_https
  certificate_arn = var.certificate_arn
}