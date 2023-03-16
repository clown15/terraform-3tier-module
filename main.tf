module "network" {
  source = "./Network"

  vpc_cidr        = var.vpc_cidr
  company         = var.company
  env             = var.env
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  db_subnets      = var.db_subnets
}

module "endpoints" {
  source = "./Endpoints"

  company        = var.company
  env            = var.env
  region         = var.region
  vpc_id         = module.network.vpc_id
  vpc_cidr       = var.vpc_cidr
  pri_web_rtb_id = module.network.pri_web_rtb_id
  pub_sub_ids    = module.network.pub_sub_ids
}

module "alb" {
  source = "./ALB"

  company     = var.company
  env         = var.env
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr
  pub_sub_ids = module.network.pub_sub_ids
  domain      = var.domain

  depends_on = [
    module.acm
  ]
}

# module "route53" {
#   source = "./Route53"

#   domain = var.domain
# }

module "acm" {
  source = "./ACM"

  domain  = var.domain
  company = var.company
}

module "iam" {
  source = "./IAM"

  company = var.company
}

module "asg" {
  source = "./ASG"
  depends_on = [
    module.alb
  ]

  company       = var.company
  env           = var.env
  albsg_id      = module.alb.albsg_id
  vpc_id        = module.network.vpc_id
  instance_type = "t3.medium"
  volume_type   = "gp3"
  iam_role      = module.iam.iam_role
  sub_ids       = module.network.web_sub_ids
  alb_id        = module.alb.alb_id
  alb_tg        = module.alb.alb_tg
}

module "s3" {
  source = "./S3"

  company     = var.company
  env         = var.env
  bucket_name = var.bucket_name
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "secretmanager" {
  source = "./SecretManager"

  secret_name = var.secret_name
  secrets = jsonencode({
    dbname     = var.dbname
    username   = var.username
    password   = random_password.password.result
    bucketname = module.s3.s3.id
  })
}

module "aurora" {
  source = "./Aurora"

  company = var.company
  env = var.env
  secret_name = var.secret_name
  vpc_id = module.network.vpc_id
  subnets = module.network.db_sub_ids
  dbname = var.dbname
  username = var.username
  password = random_password.password.result
  db_instance = var.db_instance

  depends_on = [
    module.asg,
    module.secretmanager
  ]
}
# Secret Value (Key/Value):
#     host = REFER WITH RDS ENDPOINT