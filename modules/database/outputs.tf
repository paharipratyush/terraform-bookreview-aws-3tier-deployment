# We output the primary address so the Node.js backend knows where to connect
output "primary_endpoint" {
  value = aws_db_instance.primary.address
}
