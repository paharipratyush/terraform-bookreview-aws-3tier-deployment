# ==========================================
# 1. PUBLIC ALB (Internet -> Web EC2s)
# ==========================================
resource "aws_lb" "public_alb" {
  name               = "${var.project_name}-pub-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.pub_alb_sg_id]
  subnets            = var.web_subnets
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb_listener" "pub_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# ==========================================
# 2. INTERNAL ALB (Web EC2s -> App EC2s)
# ==========================================
resource "aws_lb" "internal_alb" {
  name               = "${var.project_name}-int-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.int_alb_sg_id]
  subnets            = var.app_subnets
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-app-tg"
  port     = 3001
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path    = "/"
    matcher = "200-499"
  }
}

resource "aws_lb_listener" "int_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
