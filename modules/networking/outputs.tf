output "vpc_id" {
  value = aws_vpc.main.id
}

output "web_subnets" {
  value = [aws_subnet.web_public_a.id, aws_subnet.web_public_b.id]
}

output "app_subnets" {
  value = [aws_subnet.app_private_a.id, aws_subnet.app_private_b.id]
}

output "db_subnets" {
  value = [aws_subnet.db_private_a.id, aws_subnet.db_private_b.id]
}
