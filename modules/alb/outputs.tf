output "alb_dns" {
  value = { for k, alb in aws_lb.alb : k => alb.dns_name }
}

output "alb_name" {
  value = { for k, alb in aws_lb.alb : k => alb.name }
}

output "alb_arn_suffix" {
  value = {
    for k, alb in aws_lb.alb : k => alb.arn_suffix
  }
}

output "listener_http_arn" {
  value = [for listener in aws_lb_listener.listener_http : listener.arn]
}

output "target_group_arns" {
  value = {
    for tg_key, tg in aws_lb_target_group.tg : tg_key => tg.arn
  }
}

output "target_group_name" {
  value = {
    for tg_key, tg in aws_lb_target_group.tg : tg_key => tg.name
  }
}

output "target_group_arn_suffix" {
  value = {
    for tg_key, tg in aws_lb_target_group.tg : tg_key => tg.arn_suffix
  }
}
