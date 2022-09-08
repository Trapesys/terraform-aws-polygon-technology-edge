locals {
  secrets_manager_config = {
    token      = ""
    server_url = ""
    type       = "aws-ssm"
    namespace  = "admin"
    extra = {
      region             = data.aws_region.current.name
      ssm-parameter-path = var.assm_path
    }
  }
}

data "aws_ami" "ubuntu_20_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "template_file" "server" {
  template = file("${path.module}/templates/cloud-config.yaml.tftpl")
  vars = {
    aws_region       = data.aws_region.current.name
    polygon_edge_dir = var.polygon_edge_dir
    ebs_device       = var.ebs_device
    chain_volume_id  = aws_ebs_volume.chain_data.id
    node_name        = var.node_name
    total_nodes      = var.total_nodes
    s3_bucket_name   = var.s3_bucket_name

    secrets_manager_config = jsonencode(merge(local.secrets_manager_config, { name = var.node_name }))
    genesis_json           = var.genesis_json != "" ? jsonencode(jsondecode(file(var.genesis_json))) : ""

    premine         = var.premine
    chain_name      = var.chain_name
    chain_id        = var.chain_id
    pos             = var.pos
    epoch_size      = var.epoch_size
    block_gas_limit = var.block_gas_limit

    polygon_edge_dir   = var.polygon_edge_dir
    s3_bucket_name     = var.s3_bucket_name
    prometheus_address = var.prometheus_address
    block_gas_target   = var.block_gas_target
    nat_address        = var.nat_address
    dns_name           = var.dns_name
    price_limit        = var.price_limit
    max_slots          = var.max_slots
    block_time         = var.block_time
  }
}
data "template_cloudinit_config" "server" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.server.rendered
  }
}
