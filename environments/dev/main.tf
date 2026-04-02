module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr = "10.0.0.0/16"

  ez_websub_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  iz_appsub_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  iz_dbsub_cidr  = ["10.0.5.0/24", "10.0.6.0/24"]

  availability_zone = ["ap-southeast-1a", "ap-southeast-1b"]
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source  = "../../modules/alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  sg_id   = module.sg.alb_sg_id
}

module "nlb" {
  source  = "../../modules/nlb"
  subnets = module.vpc.private_subnets
  vpc_id  = module.vpc.vpc_id
}

module "asg_web" {
  source           = "../../modules/asg-web"
  subnets          = module.vpc.private_subnets
  sg_id            = module.sg.web_sg_id
  key_name         = module.keypair.keypair_name
  instance_profile = module.iam.instance_profile
  ami_id           = "ami-049371af5cd9af3ec"
  instance_type    = "t2.micro"
  nlb_dns          = module.nlb.nlb_dns
  target_group_arn = module.alb.target_group_arn
}

module "asg_app" {
  source           = "../../modules/asg-app"
  subnets          = module.vpc.private_subnets
  sg_id            = module.sg.app_sg_id
  key_name         = module.keypair.keypair_name
  instance_profile = module.iam.instance_profile
  ami_id           = "ami-049731af5cd9af3ec"
  instance_type    = "t2.micro"
  db_host          = ""
  target_group_arn = module.nlb.target_group_arn
}

module "iam" {
  source = "../../modules/iam"
}

module "keypair" {
  source = "../../modules/keypair"
}