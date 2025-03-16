variable "env_name" {
  type = string
}

variable "vpc_name" {
  type    = string
  default = "ms-up-running"
}

variable "public_subnet_a_cidr" {
  type = string
}

variable "public_subnet_b_cidr" {
  type = string
}

variable "private_subnet_a_cidr" {
  type = string
}

variable "private_subnet_b_cidr" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "folder_id" {
  type    = string
}

variable "cloud_id" {
  type = string
}

variable "token" {
  type = string
}