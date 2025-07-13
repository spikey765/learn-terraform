# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
   // Uncommented this block to use Terraform Cloud for this tutorial
  cloud {
    organization = "devopspracticing"
    workspaces {
      name = "learn-terraform-init"
    }
  }

}
