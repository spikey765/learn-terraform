# Specifying variables using a variables file (terraform.tfvars) to set values for variables defined in Terraform configuration. 
# Useful for keeping sensitive information out of the main configuration files and for easily changing variable values without modifying the code.
terraform {
  backend "s3" {
    bucket         = "example-tf-state-bucket"
    key            = "Variables-&-DS/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  extra_tag = "extra-tag"
}

#Refer to terraform.tfvars for variable values
resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra_tag
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "12"
  instance_class      = "db.t2.micro"
  db_name            = "mydb"
  username            = var.db_user
  password            = var.db_pass
  skip_final_snapshot = true
}