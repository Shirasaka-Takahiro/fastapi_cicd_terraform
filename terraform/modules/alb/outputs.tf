output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID (for ALIAS records)"
  value       = aws_lb.this.zone_id
}

output "blue_target_group_arn" {
  description = "Blue target group ARN"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.green.arn
}

output "blue_target_group_name" {
  description = "Blue target group name"
  value       = aws_lb_target_group.blue.name
}

output "green_target_group_name" {
  description = "Green target group name"
  value       = aws_lb_target_group.green.name
}

output "prod_listener_arn" {
  description = "Production listener (443) ARN"
  value       = aws_lb_listener.https_prod.arn
}

output "test_listener_arn" {
  description = "Test listener (8443) ARN for Blue/Green validation"
  value       = aws_lb_listener.https_test.arn
}
