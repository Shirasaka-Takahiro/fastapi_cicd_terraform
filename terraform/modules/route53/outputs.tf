output "record_fqdn" {
  description = "Registered record FQDN"
  value       = aws_route53_record.alb_alias.fqdn
}
