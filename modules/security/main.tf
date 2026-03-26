# Fetch dynamic IP for secure SSH
data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

# 1. Public ALB SG (Open to World)
resource "aws_security_group" "pub_alb_sg" {
  name        = "${var.project_name}-pub-alb-sg"
  description = "Allow HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Web EC2 SG (Only accepts traffic from Public ALB + Local SSH)
resource "aws_security_group" "web_ec2_sg" {
  name   = "${var.project_name}-web-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.pub_alb_sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Internal ALB SG (Only accepts traffic from Web EC2)
resource "aws_security_group" "int_alb_sg" {
  name   = "${var.project_name}-int-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80 # <--- MUST BE 80
    to_port         = 80 # <--- MUST BE 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. App EC2 SG (Only accepts traffic from Internal ALB + SSH from Web EC2)
resource "aws_security_group" "app_ec2_sg" {
  name   = "${var.project_name}-app-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.int_alb_sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_ec2_sg.id] # The Jump Host!
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. DB SG (Only accepts traffic from App EC2)
resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
