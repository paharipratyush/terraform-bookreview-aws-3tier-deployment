output "pub_alb_sg_id" {
  value = aws_security_group.pub_alb_sg.id
}


output "web_ec2_sg_id" {
  value = aws_security_group.web_ec2_sg.id
}


output "int_alb_sg_id" {
  value = aws_security_group.int_alb_sg.id
}


output "app_ec2_sg_id" {
  value = aws_security_group.app_ec2_sg.id
}


output "db_sg_id" {
  value = aws_security_group.db_sg.id
}
