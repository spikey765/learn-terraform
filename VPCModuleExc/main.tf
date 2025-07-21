terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  availability_zones = ["us-west-2a", "us-west-2b"]
}

provider "aws" {
  region = "us-west-2"
}

//Main VPC resource
//===========================================================================================================================================================================

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" // Main CIDR block for the VPC, 2^16 usable IPs for subnets

  tags = {
    Name = "vpc-main"
  }
}

//Conditional Public Subnets & IGW
//===========================================================================================================================================================================

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  count = var.create_public_subnets? 2 : 0
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) //Since there are 2 subnets, using cidrsubnet(prefix, newbits, netnum) to generate unique CIDR blocks for each new subnet
  availability_zone = local.availability_zones[count.index] //Using local block to distinguish AZs between subnets

  tags = {
    Name = "vpc-main-public"
  }
}

resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.main.id
  count = var.create_public_subnets? 1 : 0 //it's dependent on public subnets' creation

  tags = {
    Name = "vpc-main-public-igw"
  }
}

//Conditional Private Subnets & NGW
//===========================================================================================================================================================================

resource "aws_subnet" "private"{
  vpc_id = aws_vpc.main.id
  count = var.create_private_subnets? 2 : 0

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2) //Offset of 2 to prevent overlap w/ publics
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "vpc-main-private"
  }
}


resource "aws_eip" "eip"{ //The static IP from which the nat gateway will route traffic
  domain = "vpc"
  count = var.create_private_subnets? 1 : 0
}

resource "aws_nat_gateway" "ngw"{
  allocation_id = aws_eip.eip[0].id //Since eip is created using count therefore it's a list element
  subnet_id = aws_subnet.public[0].id //To ensure it's in the list of public subnets

  count = var.create_private_subnets? 1 : 0

  tags = {
    Name = "vpc-main-public-ngw"
  }

  depends_on = [aws_internet_gateway.igw[0]] //Since igw is created using count so it's a list element
}

//Conditional Data Subnets
//===========================================================================================================================================================================

resource "aws_subnet" "data"{ 
  vpc_id = aws_vpc.main.id

  count = var.create_data_subnets? 2 : 0
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 4) //Offset of 4 to prevent overlap w/ publics or privates
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "vpc-main-data"
  }
}

//Conditional Public Route Table & Association
//===========================================================================================================================================================================

resource "aws_route_table" "public_route_table"{
  vpc_id = aws_vpc.main.id
  count = var.create_public_subnets? 1 : 0

  route {
    cidr_block = "0.0.0.0/0" //To route all outbound traffic to the igw
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = {
    Name = "vpc-main-public-rt"
  }
}

resource "aws_route_table_association" "public"{
  count = var.create_public_subnets? 2 : 0

  subnet_id = aws_subnet.public[count.index].id //To reference the each subnet in the list
  route_table_id = aws_route_table.public_route_table[0].id
}

//Conditional Private Route Table & Association
//===========================================================================================================================================================================

resource "aws_route_table" "private_route_table"{
  vpc_id = aws_vpc.main.id
  count = var.create_private_subnets? 1 : 0

  route {
    cidr_block = "0.0.0.0/0" //To route all outbound traffic to the ngw
    nat_gateway_id = aws_nat_gateway.ngw[0].id //[0] needed as ngw was created in a list using count
  }

  tags = {
    Name = "vpc-main-private-rt"
  }
}

resource "aws_route_table_association" "private"{
  count = var.create_private_subnets? 2 : 0

  subnet_id = aws_subnet.private[count.index].id //To reference the each subnet in the list
  route_table_id = aws_route_table.private_route_table[0].id
}


//Conditional Data Route Table & Association
//===========================================================================================================================================================================

resource "aws_route_table" "data_route_table"{ //Logically isolated route table for the data subnets
  vpc_id = aws_vpc.main.id
  count = var.create_data_subnets? 1 : 0

  tags = {
    Name = "vpc-main-data-rt"
  }
}

resource "aws_route_table_association" "data"{
  count = var.create_data_subnets? 2 : 0

  route_table_id = aws_route_table.data_route_table[0].id
  subnet_id = aws_subnet.data[count.index].id
}

//Conditional VPC Endpoints (s3, ecr)
//===========================================================================================================================================================================

resource "aws_vpc_endpoint" "s3"{
  count = var.create_vpc_endpoints? 1 : 0

  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public_route_table[0].id,
    aws_route_table.private_route_table[0].id
  ]

  tags = {
    Name = "vpc-main-s3-ep"
  }
}

resource "aws_security_group" "ecr_sg"{
  count = var.create_vpc_endpoints? 1 : 0

  description = "sg for ecr endpoints"
  vpc_id = aws_vpc.main.id

  ingress{ //stateful therefore the same rules apply for egress traffic
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

resource "aws_vpc_endpoint" "ecr"{
  count = var.create_vpc_endpoints? 1 : 0

  vpc_id = aws_vpc.main.id
  service_name = "com.amazonaws.us-west-2.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ecr_sg[0].id]
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "vpc-main-ecr-ep"
  }
}

//Conditional Network ACL
//===========================================================================================================================================================================
 resource "aws_network_acl" "main"{
  count = var.create_vpc_endpoints? 1 : 0
  vpc_id = aws_vpc.main.id

  //Stateless, have to specifiy rules for bi-directional traffic
  ingress{
    rule_no = 100
    from_port = 443
    to_port = 443
    protocol = "tcp"
    action = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress{
    rule_no = 100
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    action = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "vpc-main-nacl"
  }
 }

