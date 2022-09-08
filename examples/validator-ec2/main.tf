data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "polygon-edge" {
  source = "../../."

  account_id          = data.aws_caller_identity.current.account_id
  premine             = var.premine
  region              = data.aws_region.current.name
  alb_ssl_certificate = var.alb_ssl_certificate

  genesis_path = "./genesis.json"
}
