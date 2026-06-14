variable "hosted_zone_id" {
  description = "Existing Route53 hosted zone ID"
  type        = string
}

variable "record_name" {
  description = "FQDN to register (e.g. app.example.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name to alias to"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB hosted zone ID"
  type        = string
}
