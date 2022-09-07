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

data "cloudinit_config" "main" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-config.yaml", {
      polygon_edge_dir     = var.polygon_edge_dir
      ebs_device           = var.ebs_device
      node_name            = var.node_name
      assm_path            = var.assm_path
      assm_region        = var.assm_region
      total_nodes          = var.total_nodes
      s3_bucket_name       = var.s3_bucket_name
      s3_key_name          = var.s3_key_name
      lambda_function_name = var.lambda_function_name

      premine             = var.premine
      chain_name          = var.chain_name
      chain_id            = var.chain_id
      pos                 = var.pos
      epoch_size          = var.epoch_size
      block_gas_limit     = var.block_gas_limit
      max_validator_count = var.max_validator_count
      min_validator_count = var.min_validator_count
      consensus           = var.consensus
    })
  }
}
