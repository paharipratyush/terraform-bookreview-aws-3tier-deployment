variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "project_name" {
  description = "The name of the project for tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "db_password" {
  description = "The master password for the RDS database"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}
