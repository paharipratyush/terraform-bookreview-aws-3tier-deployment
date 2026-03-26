variable "project_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ec2_size" {
  type = string
}

variable "web_subnet_id" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "web_sg_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "web_user_data" {
  type = string
}

variable "app_user_data" {
  type = string
}

variable "web_tg_arn" {
  type = string
}

variable "app_tg_arn" {
  type = string
}
