# Fetch the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1. The Web Server (Frontend)
resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_size
  subnet_id                   = var.web_subnet_id
  vpc_security_group_ids      = [var.web_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = var.web_user_data

  tags = { Name = "${var.project_name}-web-server" }
}

# Attach Web Server to the Public Target Group
resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = var.web_tg_arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# 2. The App Server (Backend)
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_size
  subnet_id                   = var.app_subnet_id
  vpc_security_group_ids      = [var.app_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  user_data                   = var.app_user_data

  tags = { Name = "${var.project_name}-app-server" }
}

# Attach App Server to the Internal Target Group
resource "aws_lb_target_group_attachment" "app_attach" {
  target_group_arn = var.app_tg_arn
  target_id        = aws_instance.app_server.id
  port             = 3001
}
