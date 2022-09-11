# Create new ALB
resource "aws_lb" "polygon_nodes" {
  name_prefix = var.nodes_alb_name_prefix
  #tfsec:ignore:aws-elb-alb-not-public
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = var.public_subnets
  security_groups            = [var.alb_sec_group]
  drop_invalid_header_fields = true


  tags = {
    Name = var.nodes_alb_name_tag
  }
}
# Create new ALB Target Group
resource "aws_lb_target_group" "polygon_nodes" {
  name_prefix          = var.nodes_alb_targetgroup_name_prefix
  port                 = 8545
  deregistration_delay = 30
  health_check {
    interval            = 15
    unhealthy_threshold = 8
  }
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Set http listener on ALB
resource "aws_lb_listener" "polygon_nodes_http" {
  load_balancer_arn = aws_lb.polygon_nodes.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = toset(var.alb_ssl_certificate == "" ? ["enabled"] : [])
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.polygon_nodes.arn
    }
  }

  dynamic "default_action" {
    for_each = toset(var.alb_ssl_certificate != "" ? ["enabled"] : [])
    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_301"
        port        = 443
        protocol    = "HTTPS"
      }
    }
  }
}
# Set https listener on ALB
resource "aws_lb_listener" "polygon_nodes_https" {
  for_each          = toset(var.alb_ssl_certificate != "" ? ["enabled"] : [])
  load_balancer_arn = aws_lb.polygon_nodes.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_ssl_certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.polygon_nodes.arn
  }
}
