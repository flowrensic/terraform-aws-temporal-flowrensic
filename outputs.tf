output "ui_url" {
  description = "Where people and allowed servers open the UI and API."
  value       = "https://${var.ui_name}"
}

output "ingest_url" {
  description = "Where CI jobs send their data."
  value       = "https://${var.ingest_name}"
}

output "ingest_load_balancer" {
  description = "The ARN of the public load balancer ingest_name points at, the module's own or the user's."
  value       = local.ingest_lb.arn
}

output "ui_load_balancer_dns_name" {
  description = "The DNS name of the module's public UI load balancer, where ui_name and, with monitoring ecs, grafana. and ui_name point from allowed_cidrs. Empty when there is none. With dns_zone empty, point the names here yourself."
  value       = local.ui_public == 1 ? aws_lb.ui_public[0].dns_name : ""
}

output "ui_internal_load_balancer_dns_name" {
  description = "The DNS name of the internal UI load balancer, the module's own or the user's, where ui_name and, with monitoring ecs, grafana. and ui_name point inside the VPC. Empty when there is none. With dns_zone empty, point the names here yourself."
  value       = local.internal == 1 ? local.internal_lb.dns_name : ""
}

output "ingest_load_balancer_dns_name" {
  description = "The DNS name of the public load balancer ingest_name points at, the module's own or the user's. With dns_zone empty, point the name here yourself."
  value       = local.ingest_lb.dns_name
}

output "bucket" {
  description = "The bucket that holds the histories."
  value       = aws_s3_bucket.histories.id
}

output "cluster" {
  description = "The ECS cluster, for put-secrets.sh --restart."
  value       = aws_ecs_cluster.this.name
}

output "service" {
  description = "The ECS service, for put-secrets.sh --restart."
  value       = aws_ecs_service.server.name
}

output "database" {
  description = "With mode full, the identifier of the RDS instance. Empty in standalone mode."
  value       = one(aws_db_instance.this[*].identifier) == null ? "" : one(aws_db_instance.this[*].identifier)
}

output "database_address" {
  description = "With mode full, the host name of the RDS instance, reached from the server only. Empty in standalone mode."
  value       = one(aws_db_instance.this[*].address) == null ? "" : one(aws_db_instance.this[*].address)
}

output "grafana_url" {
  description = "With monitoring ecs, where people open Grafana. Empty otherwise."
  value       = var.monitoring == "ecs" ? "https://${local.grafana_name}" : ""
}

output "monitoring_service" {
  description = "With monitoring ecs, the ECS service of Prometheus and Grafana. Empty otherwise."
  value       = var.monitoring == "ecs" ? aws_ecs_service.monitoring[0].name : ""
}

output "monitoring_file_system" {
  description = "With monitoring ecs, the EFS file system of the Prometheus data. Empty otherwise."
  value       = var.monitoring == "ecs" ? aws_efs_file_system.prometheus[0].id : ""
}

output "monitoring_namespace" {
  description = "With monitoring ecs, the Cloud Map namespace Prometheus finds the server in. Empty otherwise."
  value       = var.monitoring == "ecs" ? aws_service_discovery_private_dns_namespace.monitoring[0].id : ""
}

output "log_group" {
  description = "The CloudWatch log group of the server."
  value       = aws_cloudwatch_log_group.server.name
}

output "alarm_topic" {
  description = "The SNS topic the alarms go to, the user's or the module's own."
  value       = local.alarm_topic
}
