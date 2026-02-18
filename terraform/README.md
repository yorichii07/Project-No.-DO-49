# Terraform Configuration for Flask Task Application

This directory contains Terraform configuration to deploy the Flask task application to AWS using ECS Fargate, RDS PostgreSQL, and Application Load Balancer.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Internet Gateway                      │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│          Application Load Balancer (Public)              │
│                 Port 80 (and 443 if TLS)                 │
└─────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│              ECS Cluster (Fargate)                        │
│  ┌───────────────────────────────────────────────────┐   │
│  │ Task Definition (Flask Application)               │   │
│  │ - CPU: configurable (256-4096)                    │   │
│  │ - Memory: configurable                            │   │
│  │ - Port: 5000                                       │   │
│  │ - CloudWatch Logs enabled                         │   │
│  └───────────────────────────────────────────────────┘   │
│  Services: configurable number of tasks                  │
│  Auto-scaling: CPU & Memory based (optional)             │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│        RDS PostgreSQL Database (Private)                 │
│  - Multi-AZ: configurable                                │
│  - Backup retention: 7 days (default)                    │
│  - Encryption: enabled                                   │
│  - Monitoring: Enhanced Monitoring enabled               │
└──────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **AWS Account**: You need an AWS account with appropriate permissions
2. **Terraform**: Install Terraform >= 1.0
3. **AWS CLI**: Configure AWS credentials
4. **Docker**: For building and pushing the Flask application image to ECR

## File Structure

```
terraform/
├── provider.tf           # AWS provider configuration
├── variables.tf          # Input variables definition
├── terraform.tfvars      # Variable values (development)
├── terraform.tfvars.example  # Example values
├── main.tf              # Main configuration
├── networking.tf        # VPC, Subnets, Route Tables
├── security.tf          # Security Groups
├── iam.tf              # IAM Roles and Policies
├── ecr.tf              # ECR Repository
├── rds.tf              # RDS Database
├── alb.tf              # Application Load Balancer
├── ecs.tf              # ECS Cluster, Task Definition, Service
├── outputs.tf          # Output values
└── README.md           # This file
```

## Quick Start

### 1. Setup AWS Credentials

```bash
# Configure AWS CLI with your credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Build and Push Docker Image to ECR

```bash
# Initialize Terraform to create ECR repository
cd terraform
terraform init

# Create ECR repository
terraform apply -target=aws_ecr_repository.app

# Get the ECR repository URL from terraform output
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build Docker image
cd ..
docker build -t $ECR_URL:latest .

# Push to ECR
docker push $ECR_URL:latest
```

### 3. Update Terraform Variables

```bash
cd terraform

# Copy the example file and customize
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# - Set container_image to the ECR URL from step 2
# - Set db_password to a secure password
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan the Deployment

```bash
terraform plan -out=tfplan
```

### 6. Apply the Configuration

```bash
terraform apply tfplan
```

### 7. Get Application URL

```bash
terraform output application_url
```

## environment Variables

The application receives the following environment variables automatically:

```
DATABASE_URL=postgresql://user:password@host:port/database
FLASK_ENV=development|production (based on environment)
PORT=5000
```

Update your Flask application's `app.py` to read from `DATABASE_URL`:

```python
from os import environ
DATABASE_URL = environ.get('DATABASE_URL', 'sqlite:///database.db')
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
```

## Scaling Configuration

### Auto-Scaling

Enable auto-scaling in `terraform.tfvars`:

```hcl
enable_autoscaling = true
min_capacity = 1
max_capacity = 5
```

This will scale based on:
- **CPU**: Target 70% average utilization
- **Memory**: Target 80% average utilization

### Manual Scaling

Change `desired_count` in `terraform.tfvars`:

```hcl
desired_count = 2  # Run 2 tasks
```

Then apply:

```bash
terraform apply
```

## Database Configuration

### Production Setup

For production, update `terraform.tfvars`:

```hcl
environment          = "prod"
db_instance_class    = "db.t3.small"  # or larger
db_allocated_storage = 100
db_multi_az         = true
db_backup_retention_days = 30
```

Then apply:

```bash
terraform apply
```

### Accessing Database

```bash
# Get database endpoint
terraform output rds_address

# Connect with psql
psql -h <rds_address> -U flaskadmin -d flaskdb
```

## HTTPS/TLS Configuration

To enable HTTPS:

1. Create an ACM certificate in AWS
2. Update `terraform.tfvars`:

```hcl
enable_https        = true
ssl_certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
```

3. Apply changes:

```bash
terraform apply
```

HTTP requests will automatically redirect to HTTPS.

## Monitoring and Logs

### CloudWatch Logs

View application logs:

```bash
# Get log group name
LOG_GROUP=$(terraform output cloudwatch_log_group)

# View logs
aws logs tail $LOG_GROUP --follow
```

### ECS Metrics

Access CloudWatch dashboard for:
- CPU utilization
- Memory utilization
- Task counts
- ALB request metrics

## Updating Application Code

When you update the Flask application:

1. Build and push new Docker image:

```bash
docker build -t $ECR_URL:latest .
docker push $ECR_URL:latest
```

2. Update ECS service to use new image:

```bash
# Get cluster and service names
CLUSTER=$(terraform output ecs_cluster_name)
SERVICE=$(terraform output ecs_service_name)

# Force new deployment
aws ecs update-service \
  --cluster $CLUSTER \
  --service $SERVICE \
  --force-new-deployment
```

Or simply re-apply Terraform:

```bash
terraform apply
```

## Destroying Resources

To remove all resources:

```bash
terraform destroy
```

**Warning**: This will delete the database. Back up your data first if needed.

## Cost Optimization

### Development Environment

- Use `db.t3.micro` for database (free tier eligible)
- Set `desired_count = 1` for single task
- Set `enable_autoscaling = false`
- Use `db_backup_retention_days = 7`
- Disable Multi-AZ

Estimated cost: **~$15-30/month**

### Production Environment

The current configuration provides high availability. Monthly cost: **$150-300+**

## Troubleshooting

### Application not accessible

1. Check ALB health:

```bash
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

2. View ECS task logs:

```bash
LOG_GROUP=$(terraform output cloudwatch_log_group)
aws logs tail $LOG_GROUP
```

### Database connection errors

1. Verify security group rules allow ECS → RDS

2. Test connection:

```bash
psql -h <rds_address> -U flaskadmin -d flaskdb
```

3. Check RDS parameter: `max_connections` (default: 100)

### High latency

1. Increase container CPU/memory:

```hcl
container_cpu    = 512
container_memory = 1024
```

2. Enable connection pooling in Flask

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

## Support

For issues or questions, refer to:

1. Terraform documentation: `terraform -help`
2. AWS CloudFormation equivalent operations
3. AWS Support console
