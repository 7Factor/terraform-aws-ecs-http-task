module "app_lb" {
  source = "github.com/7Factor/terraform-aws-app-load-balancer"

  cluster_name = var.cluster_name
  app_name     = var.app_name

  internal                 = var.lb_internal
  security_groups          = var.lb_security_groups
  subnets                  = var.lb_subnets
  idle_timeout             = var.lb_idle_timeout
  ssl_policy               = var.lb_security_policy
  certificate_arn          = var.lb_certificate_arn
  secure_listener_redirect = var.lb_secure_listener_redirect
  access_logs_enabled      = var.lb_access_logs_enabled
  access_logs_bucket       = var.lb_access_logs_bucket

  target_group_arn = aws_lb_target_group.lb_targets.arn
}

resource "aws_lb_target_group" "lb_targets" {
  name                 = substr("tg-${var.cluster_name}-${var.app_name}", 0, min(length("lb-${var.cluster_name}-${var.app_name}"), 32))
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = "60"

  health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  lifecycle {
    create_before_destroy = true
  }
}
