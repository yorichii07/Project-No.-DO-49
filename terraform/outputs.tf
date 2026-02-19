# ============================================================================
# TERRAFORM OUTPUTS
# ============================================================================
# This file contains all output values from the Terraform infrastructure
#
# Outputs are displayed after terraform apply and can be referenced by:
#   terraform output [output_name]
#
# Sensitive outputs are marked and won't be displayed in logs

# ============================================================================
# APPLICATION ACCESS
# ============================================================================

output "application_url" {
  description = "URL of the application (HTTP or HTTPS)"
  value       = "http://${aws_lb.main.dns_name}"
}

# ============================================================================
# GENERAL INFORMATION
# ============================================================================

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name (dev, staging, prod)"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

# ============================================================================
# NETWORKING
# ============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

# ============================================================================
# ECS (Elastic Container Service)
# ============================================================================

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}

# ============================================================================
# DATABASE (RDS PostgreSQL)
# ============================================================================

output "rds_endpoint" {
  description = "RDS database endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS database hostname"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "RDS database name"
  value       = var.db_name
}

output "db_username" {
  description = "RDS database master username"
  value       = var.db_username
  sensitive   = true
}

# ============================================================================
# CONTAINER REGISTRY (ECR)
# ============================================================================

output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}

# ============================================================================
# LOGGING
# ============================================================================

output "cloudwatch_log_group" {
  description = "CloudWatch log group name for application logs"
  value       = aws_cloudwatch_log_group.app.name
}

# ============================================================================
# USAGE EXAMPLES
# ============================================================================

output "usage_examples" {
  description = "Common commands to manage the deployment"
  value = {
    "Visit_App"          = "open http://${aws_lb.main.dns_name}",
    "View_Logs"          = "aws logs tail ${aws_cloudwatch_log_group.app.name} --follow",
    "Scale_to_3_Tasks"   = "terraform apply -var='desired_count=3'",
    "Connect_to_DB"      = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name}",
    "Get_All_Outputs"    = "terraform output -json"
  }
  sensitive = true
}
