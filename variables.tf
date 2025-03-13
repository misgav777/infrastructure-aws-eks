variable "project" {
  description = "The project in which the resources are created"
  type        = string
}

#Variables for the VPC
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "The region in which the VPC will be created"
  type        = string
}

variable "AZs" {
  type = list(string)
}

variable "eks_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "The version of the EKS cluster"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EKS nodes"
  type        = string
}