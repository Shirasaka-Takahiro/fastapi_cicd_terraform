output "db_instance_id" {
  description = "DB instance identifier"
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "DB endpoint (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "DB hostname"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "DB port"
  value       = aws_db_instance.this.port
}
