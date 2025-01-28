resource "aws_lb" "alb" {
  for_each = var.alb_configs

  name = join("-", compact([
    var.environment,
    lookup(each.value, "product", ""),
    lookup(each.value, "service", ""),
    "ALB"
  ]))
  internal           = try(each.value.internal, false)
  load_balancer_type = "application"
  security_groups    = each.value.alb_security_groups
  subnets            = each.value.subnets
  idle_timeout       = 60

  tags = {
    Name = join("-", compact([
      var.environment,
      lookup(each.value, "product", ""),
      lookup(each.value, "service", ""),
      "ALB"
    ]))
    Environment = try(var.environment, "")
    Product     = try(each.value.product, "")
    Service     = try(each.value.service, "")
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = var.target_groups

  name = join("-", compact([
    var.environment,
    lookup(each.value, "product", ""),
    lookup(each.value, "service", ""),
    "TG"
  ]))
  port                 = each.value.port
  protocol             = each.value.protocol
  target_type          = each.value.target_type
  deregistration_delay = "60"
  vpc_id               = each.value.vpc_id

  health_check {
    interval            = try(each.value.health_check_interval, 60)
    healthy_threshold   = try(each.value.healthy_threshold, 2)
    unhealthy_threshold = try(each.value.unhealthy_threshold, 2)
    timeout             = try(each.value.health_check_timeout, 30)
    matcher             = try(each.value.health_check_matcher, "200-399")
    path                = try(each.value.health_check_path, "/health")
  }

  tags = {
    Name = join("-", compact([
      var.environment,
      lookup(each.value, "product", ""),
      lookup(each.value, "service", ""),
      "TG"
    ]))
    Environment = var.environment
    Product     = try(each.value.product, "")
    Service     = try(each.value.service, "")
  }
}

resource "aws_lb_listener" "listener_http" {
  for_each          = var.listener_http

  load_balancer_arn = aws_lb.alb[each.value.alb].arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type = each.value.default_http_action_type
    target_group_arn = each.value.default_http_action_type == "redirect" ? null : aws_lb_target_group.tg[each.value.tg].arn

    dynamic "redirect" {
      for_each = each.value.default_http_action_type == "redirect" ? [1] : []

      content {
        port        = each.value.redirect_http_port
        protocol    = each.value.redirect_http_protocol
        status_code = each.value.redirect_http_status_code
      }
    }
  }

  depends_on = [aws_lb.alb]
}

resource "aws_lb_listener" "listener_https" {
  for_each          = var.listener_https

  load_balancer_arn = aws_lb.alb[each.value.alb].arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.ssl_certificate_arn

  default_action {
    type             = each.value.default_https_action_type
    target_group_arn = aws_lb_target_group.tg[each.value.tg].arn
  }

  depends_on = [aws_lb.alb]
}

resource "aws_lb_listener_rule" "listener_rule_https" {
  for_each     = var.listener_rules

  listener_arn = aws_lb_listener.listener_https[each.value.listener].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.value.tg].arn
  }

  condition {
    host_header {
      values = each.value.host_header_values
    }
  }
}
