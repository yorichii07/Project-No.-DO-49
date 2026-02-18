# Terraform Variables for Development Environment
# Update these values according to your needs

aws_region      = "us-east-1"
project_name    = "flask-app"
environment     = "dev"
app_name        = "flask-task-app"

# Container configuration
container_cpu    = 256
container_memory = 512
container_port   = 5000
desired_count    = 1

# Auto-scaling
enable_autoscaling = false
min_capacity       = 1
max_capacity       = 3

# Database configuration
db_engine           = "postgres"
db_engine_version   = "15.3"
db_instance_class   = "db.t3.micro"
db_allocated_storage = 20
db_name             = "flaskdb"
db_username         = "flaskadmin"
# db_password should be provided via command line: -var="db_password=your_secure_password"
# OR set it in a separate terraform.tfvars file (not committed to version control)
db_backup_retention_days = 7
db_multi_az              = false

# VPC configuration
vpc_cidr = "10.0.0.0/16"

# HTTPS configuration (optional)
enable_https = false
# ssl_certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"

# CloudWatch logs
log_retention_days = 30

# Container image - Update after building and pushing to ECR
# Format: {account-id}.dkr.ecr.{region}.amazonaws.com/{repository-name}:latest
# container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/flask-app-dev-repo:latest"
