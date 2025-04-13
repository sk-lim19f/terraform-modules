output "vpc_id" {
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public_subnets : s.id]
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private_subnets : s.id]
}

output "mgmt_subnets_ids" {
  value       = [for s in aws_subnet.mgmt_subnets : s.id]
}

output "db_subnet_ids" {
  value       = [for s in aws_subnet.db_subnets : s.id]
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
}
