variable "aws_region" {
  description = "The AWS region for deployment."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "A unique name for the project to prefix resources."
  type        = string
  default     = "sfn-demo"
}

