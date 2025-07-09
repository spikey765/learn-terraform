# Minimal local backend configuration for development
# This Terraform configuration sets up a minimal AWS instance using the local backend.
# Terraform will create an EC2 instance in the specified AWS region.
# Terraform command cycle:
# 1. `terraform init` - Initialize the Terraform configuration.
# 2. `terraform plan` - Create an execution plan.
# 3. `terraform apply` - Apply the changes required to reach the desired state of the configuration.
# 4. `terraform destroy` - Destroy the created resources.
# terraform fmt will format the code to a canonical format and style.
# terraform validate will check whether the configuration is syntactically valid and internally consistent.

terraform {
  cloud {
      organization = "devopspracticing"
      workspaces {
        name = "learn-terraform-aws"
      }
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Provider source, which is the official AWS provider for Terraform. Providers are plugins that allow Terraform to interact with cloud providers, SaaS providers, and other APIs.
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" { # Resource block defines an AWS EC2 instance, first the type of resource (aws_instance) and then the name (app_server).
  ami = "ami-08d70e59c07c61a3a" 
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}

