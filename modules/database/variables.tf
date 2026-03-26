variable "project_name" {
  type = string
}

variable "db_subnets" {
  type = list(string)
}

variable "db_sg_id" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
