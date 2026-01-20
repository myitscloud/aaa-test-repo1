# Production Environment Configuration

terraform {
  required_version = ">= 1.5.0"

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "production/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Deploy the application module
module "app" {
  source = "../../modules/app"

  project_name = var.project_name
  environment  = "production"
  aws_region   = var.aws_region

  # Networking - full high-availability setup
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Load Balancer
  certificate_arn = var.certificate_arn

  # ECS - production-grade instances
  container_image = var.container_image
  app_port        = 8000
  task_cpu        = 512
  task_memory     = 1024
  desired_count   = 3
  min_capacity    = 2
  max_capacity    = 20
  log_level       = "info"

  # Database - production-grade
  db_instance_class        = "db.t3.medium"
  db_allocated_storage     = 50
  db_max_allocated_storage = 500
  db_name                  = "app_production"
  db_username              = var.db_username
  db_password              = var.db_password

  # Secrets
  app_secret_key = var.app_secret_key

  tags = {
    CostCenter  = "production"
    Criticality = "high"
  }
}

# CloudWatch Alarms for Production
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-production-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU utilization is too high"

  dimensions = {
    ClusterName = module.app.ecs_cluster_name
    ServiceName = module.app.ecs_service_name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.project_name}-production-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Memory utilization is too high"

  dimensions = {
    ClusterName = module.app.ecs_cluster_name
    ServiceName = module.app.ecs_service_name
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-production-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Too many 5XX errors"

  dimensions = {
    LoadBalancer = module.app.alb_arn
  }

  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
}

# Outputs
output "alb_dns_name" {
  value = module.app.alb_dns_name
}

output "application_url" {
  value = module.app.application_url
}

output "ecs_cluster_name" {
  value = module.app.ecs_cluster_name
}

output "db_endpoint" {
  value     = module.app.db_endpoint
  sensitive = true
}

output "vpc_id" {
  value = module.app.vpc_id
}
