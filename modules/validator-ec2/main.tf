# validator autoscaling group
resource "aws_autoscaling_group" "node" {
  name_prefix = "${var.node_name}-"
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
    ]
  }
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 0
  availability_zones        = [var.az]
  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"
  }
  target_group_arns = [
    var.alb_target_group_arn
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }
  tag {
    key                 = "Name"
    value               = var.node_name
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = var.propagated_asg_tags
    content {
      key                 = each.key
      value               = each.value
      propagate_at_launch = true
    }
  }
}

# validator node launch template
resource "aws_launch_template" "node" {
  name_prefix   = "pedge-vnode-"
  image_id      = data.aws_ami.ubuntu_20_04.id
  instance_type = var.instance_type
  user_data     = data.template_cloudinit_config.server.rendered

  monitoring {
    enabled = var.instance_monitoring_enabled
  }

  iam_instance_profile {
    name = var.instance_iam_role
  }

  network_interfaces {
    network_interface_id = aws_network_interface.main.id
    device_index         = 0
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

# EBS volume to store chain data
#tfsec:ignore:aws-ebs-encryption-customer-key
resource "aws_ebs_volume" "chain_data" {
  availability_zone = var.az
  size              = var.chain_data_ebs_volume_size
  encrypted         = true

  tags = {
    Name = var.chain_data_ebs_name_tag
  }
}

# validator node ENI
resource "aws_network_interface" "main" {
  subnet_id       = var.internal_subnet
  security_groups = var.internal_sec_groups

  tags = {
    Name = var.instance_interface_name_tag
  }
}

# validator ALB TG ASG Attachment
resource "aws_autoscaling_attachment" "main" {
  lb_target_group_arn    = var.alb_target_group_arn
  autoscaling_group_name = aws_autoscaling_group.node.id
}
