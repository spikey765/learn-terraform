variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-west-2"
}

# variable "project_name" {
#   description = "Name of the project. Used in resource names and tags."
#   type        = string
#   default     = "client-webapp"
# }

# variable "environment" {
#   description = "Value of the 'Environment' tag."
#   type        = string
#   default     = "dev"
# }

# variable "public_subnets_per_vpc" {
#   description = "Number of public subnets. Maximum of 16."
#   type        = number
#   default     = 2
# }

# variable "private_subnets_per_vpc" {
#   description = "Number of private subnets. Maximum of 16."
#   type        = number
#   default     = 2
# }

# variable "instance_type" {
#   description = "Type of EC2 instance to use."
#   type        = string
#   default     = "t2.micro"
# }

variable "vpc_cidr_block" {
  description = "CIDR block for VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24",
    "10.0.15.0/24",
    "10.0.16.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
    "10.0.109.0/24",
    "10.0.110.0/24",
    "10.0.111.0/24",
    "10.0.112.0/24",
    "10.0.113.0/24",
    "10.0.114.0/24",
    "10.0.115.0/24",
    "10.0.116.0/24"
  ]
}

# This entire block defines an "input variable" for your Terraform project.
# Variables make your code reusable and easy to configure without changing the core logic.
variable "project" {

  # The description provides a human-friendly explanation of what this variable is for.
  # This text is used when generating documentation or in user interfaces.
  description = "Map of project names to configuration."

  # 'type' defines what kind of data this variable accepts.
  # 'map(any)' means it's a collection of key-value pairs (like a dictionary),
  # where the value can be of 'any' type (number, string, another map, etc.).
  type        = map(any)

  # The 'default' block provides a value to use if no other value is provided.
  # This makes your configuration runnable out of the box without needing extra files.
  default = {

    # This section defines the configuration for a project named "client-webapp".
    # "client-webapp" is a key in the main map.
    client-webapp = {

      # In AWS, this would mean: "For this project, create 2 public subnets per VPC."
      public_subnets_per_vpc  = 2,

      # Similarly, this means: "Create 2 private subnets per VPC."
      private_subnets_per_vpc = 2,

      # This means: "Inside each subnet, launch 2 EC2 server instances."
      instances_per_subnet    = 2,

      # This specifies the size of the AWS EC2 instances. 't2.micro' is small and often free.
      instance_type           = "t2.micro",

      # This is a custom label, often used for tagging resources to organize them by environment.
      environment             = "dev"
    },

    # This section defines the configuration for a different project named "internal-webapp".
    # It has different settings, showing the flexibility of this approach.
    internal-webapp = {
      public_subnets_per_vpc  = 1,
      private_subnets_per_vpc = 1,
      instances_per_subnet    = 2,
      
      # This project uses a smaller EC2 instance type.
      instance_type           = "t2.nano",

      # This project is labeled for the "test" environment.
      environment             = "test"
    }
  }
}

