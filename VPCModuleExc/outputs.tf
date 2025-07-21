# outputs.tf

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

//==========================================================================================================================================================================

output "public_subnet_ids" {
  description = "A list of the public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "data_subnet_ids" {
  description = "A list of the data subnet IDs."
  value       = aws_subnet.data[*].id
}

//==========================================================================================================================================================================

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway."
  # Check if eip was created before attempting to take the output
  value       = length(aws_eip.eip) > 0 ? aws_eip.eip[0].public_ip : null
}