variable "create_public_subnets" {
  description = "Flag to indicate creation/deletion of public subnets"
  type = bool
  default = true
}

variable "create_private_subnets" {
    description = "Flag to indicate creation/deletion of private subnets"
    type = bool
    default = true
}

variable "create_data_subnets" {
  description = "Flag to indicate creation/deletion of data subnets"
  type = bool
  default = true
}

variable "create_vpc_endpoints"{
    description = "Flag to indicate whether to create VPC endpoints or not"
    type = bool
    default = true
}