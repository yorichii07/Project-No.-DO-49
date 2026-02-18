# ============================================================================
# VPC and Networking Resources
# ============================================================================
# This file contains all networking components:
# - VPC and subnets (public and private)
# - Internet Gateway and NAT Gateways
# - Route tables and routing
# - Security Groups for ALB, ECS tasks, and RDS

# ============================================================================
# VPC SETUP
# ============================================================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-vpc"
  })
}

# ============================================================================
# INTERNET GATEWAY
# ============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-igw"
  ============================================================================
# SUBNETS: PUBLIC (for ALB)
# ============================================================================

}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-public-subnet-${count.index + 1}"
  ============================================================================
# SUBNETS: PRIVATE (for ECS tasks and RDS)
# ============================================================================

}

# Private Subnets
resource "aws_subnet" "private" {
  count              = 2
  vpc_id             = aws_vpc.main.id
  cidr_block         = "10.0.${count.index + 11}.0/24"
  availability_zone  = data.aws_availability_zones.available.names[count.index]
============================================================================
# NAT GATEWAYS (for private subnet internet access)
# ============================================================================

# 
  tags = merge(local.common_tags, {
    Name = "${local.app_name}-private-subnet-${count.index + 1}"
  })
}

# Elastic IPs for NAT
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  ============================================================================
# ROUTE TABLES
# ============================================================================

# Public Route Table (routes to Internet Gateway).common_tags, {
    Name = "${local.app_name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.ap (routes to NAT Gateway)p_name}-public-rt"
  })
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-private-rt-${count.index + 1}"
  })
}
============================================================================
# SECURITY GROUPS
# ============================================================================

# ALB Security Group - allows inbound HTTP/HTTPS from internet
resource "aws_security_group" "alb" {
  name        = "${local.app_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-alb-sg"
  })
}

# ECS Tasks Security Group - allows traffic from ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${local.app_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-ecs-tasks-sg"
  })
}

# RDS Security Group - allows PostgreSQL traffic from ECS tasks
resource "aws_security_group" "rds" {
  name        = "${local.app_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.app_name}-rds-sg"
  })
}

# ============================================================================
# DATA SOURCES
# ============================================================================

# Get available AZs for the current region
# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
