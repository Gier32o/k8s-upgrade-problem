variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "access_cidrs" {
  type = list(string)
}

variable "default_tags" {
  type = map(any)
  default = {}
}

variable "ami_id" {
  type = string
}

variable "vpc_cni_version" {
  type = string
}

variable "kubernetes_version" {
  type = string
}