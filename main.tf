# ==========================================
# 1. NETWORKING MODULE
# ==========================================
module "networking" {
  source       = "./modules/networking"
  aws_region   = var.aws_region
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

# ==========================================
# 2. SECURITY MODULE
# ==========================================
module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
}

# ==========================================
# 3. DATABASE MODULE
# ==========================================
module "database" {
  source       = "./modules/database"
  project_name = var.project_name
  db_subnets   = module.networking.db_subnets
  db_sg_id     = module.security.db_sg_id
  db_password  = var.db_password
}

# ==========================================
# 4. LOAD BALANCING MODULE
# ==========================================
module "loadbalancing" {
  source        = "./modules/loadbalancing"
  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  web_subnets   = module.networking.web_subnets
  app_subnets   = module.networking.app_subnets
  pub_alb_sg_id = module.security.pub_alb_sg_id
  int_alb_sg_id = module.security.int_alb_sg_id
}

# ==========================================
# 5. COMPUTE MODULE
# ==========================================
module "compute" {
  source       = "./modules/compute"
  project_name = var.project_name
  key_name     = var.key_name
  ec2_size     = "t2.micro"

  web_subnet_id = module.networking.web_subnets[0] # Placing in AZ-A
  app_subnet_id = module.networking.app_subnets[0] # Placing in AZ-A

  web_sg_id = module.security.web_ec2_sg_id
  app_sg_id = module.security.app_ec2_sg_id

  web_tg_arn = module.loadbalancing.web_tg_arn
  app_tg_arn = module.loadbalancing.app_tg_arn

  # Injecting the scripts and passing the output variables!
  app_user_data = templatefile("${path.module}/scripts/backend.sh.tpl", {
    db_host        = module.database.primary_endpoint
    db_pass        = var.db_password
    public_alb_dns = module.loadbalancing.public_alb_dns
  })

  web_user_data = templatefile("${path.module}/scripts/frontend.sh.tpl", {
    internal_alb_dns = module.loadbalancing.internal_alb_dns
    public_alb_dns   = module.loadbalancing.public_alb_dns
  })
}
