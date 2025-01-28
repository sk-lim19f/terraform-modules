output "ops_apm_alb_dns" {
  value = aws_lb.alb["ops_apm_alb"].dns_name
}

output "listener_http_arn" {
  value       = [for listener in aws_lb_listener.listener_http : listener.arn]
}

output "target_group_arns" {
  value = {
    for tg_key, tg in aws_lb_target_group.tg : tg_key => tg.arn
  }
}
