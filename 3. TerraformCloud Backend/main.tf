
# This Terraform configuration sets up a minimal AWS instance using the Terraform Cloud backend.
# Terraform cloud backend allows state files to be stored remotely, enabling collaboration and state management across teams.

terraform {
  cloud {
    organization = "organization-name"
    workspaces {
      name = "learn-terraform-aws"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}