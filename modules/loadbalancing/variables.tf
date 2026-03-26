variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "web_subnets" {
  type = list(string)
}

variable "app_subnets" {
  type = list(string)
}

variable "pub_alb_sg_id" {
  type = string
}

variable "int_alb_sg_id" {
  type = string
}
