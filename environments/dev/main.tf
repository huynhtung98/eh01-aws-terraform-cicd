module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr = var.vpc_cidr

  ez_websub_cidr = var.ez_websub_cidr
  iz_appsub_cidr = var.iz_appsub_cidr
  iz_dbsub_cidr  = var.iz_dbsub_cidr

  availability_zone = var.availability_zone
}

module "sg" {
  source = "../../modules/sg"

  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = module.vpc.vpc_cidr
  app_subnet_cidrs = module.vpc.private_app_subnet_cidrs
}

module "iam" {
  source = "../../modules/iam"
}

module "keypair" {
  source = "../../modules/keypair"
}

module "alb" {
  source = "../../modules/alb"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_web_subnets
  sg_id   = module.sg.alb_sg_id
}

module "nlb" {
  source = "../../modules/nlb"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_app_subnets
}

module "asg_web" {
  source = "../../modules/asg-web"

  subnets          = module.vpc.public_web_subnets
  sg_id            = module.sg.web_sg_id
  key_name         = module.keypair.keypair_name
  instance_profile = module.iam.instance_profile
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  nlb_dns          = module.nlb.nlb_dns
  target_group_arn = module.alb.target_group_arn
}

module "asg_app" {
  source = "../../modules/asg-app"

  subnets          = module.vpc.private_app_subnets
  sg_id            = module.sg.app_sg_id
  key_name         = module.keypair.keypair_name
  instance_profile = module.iam.instance_profile
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  db_host          = module.rds.db_endpoint
  db_name          = module.rds.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  target_group_arn = module.nlb.target_group_arn
}

module "rds" {
  source = "../../modules/rds"

  subnets     = module.vpc.private_db_subnets
  sg_id       = module.sg.db_sg_id
  db_username = var.db_username
  db_password = var.db_password
}
