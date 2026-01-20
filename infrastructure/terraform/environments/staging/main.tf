# Staging Environment Configuration

terraform {
  required_version = ">= 1.5.0"

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "staging/terraform.tfstate"
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
      Environment = "staging"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Deploy the application module
module "app" {
  source = "../../modules/app"

  project_name = var.project_name
  environment  = "staging"
  aws_region   = var.aws_region

  # Networking - smaller footprint for staging
  vpc_cidr             = "10.1.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24"]

  # Load Balancer
  certificate_arn = var.certificate_arn

  # ECS - smaller instances for staging
  container_image = var.container_image
  app_port        = 8000
  task_cpu        = 256
  task_memory     = 512
  desired_count   = 1
  min_capacity    = 1
  max_capacity    = 3
  log_level       = "debug"

  # Database - smaller for staging
  db_instance_class        = "db.t3.micro"
  db_allocated_storage     = 20
  db_max_allocated_storage = 50
  db_name                  = "app_staging"
  db_username              = var.db_username
  db_password              = var.db_password

  # Secrets
  app_secret_key = var.app_secret_key

  tags = {
    CostCenter = "development"
  }
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
