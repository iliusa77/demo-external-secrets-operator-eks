variable "project" {
  default = "demo-externalsecrets"
}

variable "aws_secretsmanager_secret_name" {
  default = "demo-externalsecrets-redis-password7"
}

variable "region" {
  default = "eu-west-1"
}

variable "profile" {
    description = "AWS credentials profile you want to use"
}