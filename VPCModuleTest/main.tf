provider "aws" {
    region = "us-west-2"
}

module "my_vpc"{
    source = "../VPCModuleExc" //Module root 

    //Setting modules either here or in tfvars file.
    /*
    create_public_subnets = true
    create_private_subnets = true
    create_data_subnets = true
    create_vpc_endpoints = true
    */
}

output "created_public_subnet_ids"{
    description = "The IDs of the public subnets I just made"
    value =  module.my_vpc.public_subnet_ids
}
