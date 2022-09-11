module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "= 1.4.1"

  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
  az_count   = 4

  subnets = {
    public = {
      netmask = 24
      #nat_gateway_configuration = "none"
      nat_gateway_configuration = "all_azs"
    }

    private = {
      netmask = 24
      #route_to_nat = false
      route_to_nat = true
    }
  }

  vpc_flow_logs = {
    log_destination_type = "cloud-watch-logs"
    retention_in_days    = 180
  }
}

locals {
  package_url     = var.lambda_function_zip
  downloaded      = basename(var.lambda_function_zip)
  azs             = slice(data.aws_availability_zones.current.names, 0, 4)
  private_subnets = [for _, value in module.vpc.private_subnet_attributes_by_az : value.id]
  private_azs = {
    for idx, az_name in local.azs : idx => az_name
  }

}

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 3.3.0"

  bucket_prefix = var.s3_bucket_prefix
  acl           = "private"
  force_destroy = var.s3_force_destroy
}

module "security" {
  source = "./modules/security"

  vpc_id                   = module.vpc.vpc_attributes.id
  account_id               = var.account_id
  s3_shared_bucket_name    = module.s3.s3_bucket_id
  ssm_parameter_id         = var.ssm_parameter_id
  region                   = var.region
  internal_sec_gr_name_tag = var.internal_sec_gr_name_tag
  alb_sec_gr_name_tag      = var.alb_sec_gr_name_tag
  alb_ip_whitelist         = var.alb_ip_whitelist
}

module "validator_ec2" {
  source = "./modules/validator-ec2"

  for_each = local.private_azs

  internal_subnet             = local.private_subnets[each.key]
  internal_sec_groups         = [module.security.internal_sec_group_id]
  instance_iam_role           = module.security.ec2_to_assm_iam_policy_id
  az                          = each.value
  instance_type               = var.instance_type
  instance_name               = var.instance_name
  ebs_root_name_tag           = var.ebs_root_name_tag
  instance_interface_name_tag = var.instance_interface_name_tag
  chain_data_ebs_volume_size  = var.chain_data_ebs_volume_size
  chain_data_ebs_name_tag     = var.chain_data_ebs_name_tag

  node_name      = "${var.node_name_prefix}-${each.value}"
  s3_bucket_name = module.s3.s3_bucket_id
  total_nodes    = length(module.vpc.private_subnet_attributes_by_az)
  genesis_path   = var.genesis_path

  polygon_edge_dir     = var.polygon_edge_dir
  ebs_device           = var.ebs_device
  assm_path            = var.ssm_parameter_id
  alb_target_group_arn = module.alb.alb_target_group_arn

  # Server configuration

  max_slots          = var.max_slots
  block_time         = var.block_time
  prometheus_address = var.prometheus_address
  block_gas_target   = var.block_gas_target
  nat_address        = var.nat_address
  dns_name           = var.dns_name
  price_limit        = var.price_limit

  #  # Chain configuration
  premine         = var.premine
  chain_name      = var.chain_name
  chain_id        = var.chain_id
  block_gas_limit = var.block_gas_limit
  epoch_size      = var.epoch_size
  pos             = var.pos


}

/*
module "user_data" {
  source = "./modules/user-data"

  for_each  = local.private_azs
  node_name = "${var.node_name_prefix}-${each.value}"

  assm_path      = var.ssm_parameter_id
  assm_region    = var.region
  s3_bucket_name = module.s3.s3_bucket_id
  s3_key_name    = var.s3_key_name
  total_nodes    = length(module.vpc.private_subnet_attributes_by_az)

  polygon_edge_dir = var.polygon_edge_dir
  ebs_device       = var.ebs_device

  # Server configuration

  max_slots          = var.max_slots
  block_time         = var.block_time
  prometheus_address = var.prometheus_address
  block_gas_target   = var.block_gas_target
  nat_address        = var.nat_address
  dns_name           = var.dns_name
  price_limit        = var.price_limit

  #  # Chain configuration
  premine              = var.premine
  chain_name           = var.chain_name
  chain_id             = var.chain_id
  block_gas_limit      = var.block_gas_limit
  epoch_size           = var.epoch_size
  lambda_function_name = var.lambda_function_name
  pos                  = var.pos

}

*/
module "alb" {
  source = "./modules/alb"

  public_subnets      = [for _, value in module.vpc.public_subnet_attributes_by_az : value.id]
  alb_sec_group       = module.security.jsonrpc_sec_group_id
  vpc_id              = module.vpc.vpc_attributes.id
  alb_ssl_certificate = var.alb_ssl_certificate

  nodes_alb_name_prefix             = var.nodes_alb_name_prefix
  nodes_alb_name_tag                = var.nodes_alb_name_tag
  nodes_alb_targetgroup_name_prefix = var.nodes_alb_targetgroup_name_prefix
}
