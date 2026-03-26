resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnets
  tags       = { Name = "${var.project_name}-db-subnet-group" }
}

# Strictly Free-Tier Eligible Single-AZ Database
resource "aws_db_instance" "primary" {
  identifier             = "${var.project_name}-db-primary"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "bookreview"
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  tags = { Name = "${var.project_name}-db-primary" }
}
