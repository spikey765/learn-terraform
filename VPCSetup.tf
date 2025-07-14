# 1. Configure the AWS Provider
provider "aws" {
  region = "us-west-2" //Specify the AWS region to create the resources in
}

# 2. Create the VPC Resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" // 2^16 IP Addresses

  tags = {
    Name = "my-first-vpc-tf" // All resources in the VPC have this tag
  }
}

# 3. Create the Internet Gateway and attach it
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-first-vpc-tf-igw"
  }
}

# 4. Create the Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2" # Ensure this AZ is available in the region

  tags = {
    Name = "my-first-vpc-tf-public-subnet"
  }
}

# 5. Create a Route Table for the Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # This route sends all outbound traffic (0.0.0.0/0) to the Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-first-vpc-tf-public-rt"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 6. Create the NAT Gateway 
#    A NAT Gateway needs an Elastic IP (a static public IP address) to function.
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id  // Associate the Elastic IP with the NAT Gateway
  subnet_id     = aws_subnet.public.id # The NAT Gateway must live in a public subnet

  tags = {
    Name = "my-first-vpc-tf-nat-gw"
  }

  # Ensure the Internet Gateway is created before the NAT Gateway
  depends_on = [aws_internet_gateway.gw]
}

# 7. Create the Private Subnet 
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2"

  tags = {
    Name = "my-first-vpc-tf-private-subnet"
  }
}

# 8. Create a Route Table for the Private Subnet 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # This route sends all outbound traffic (0.0.0.0/0) to the NAT Gateway.
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "my-first-vpc-tf-private-rt"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
