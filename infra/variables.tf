variable "vpc_name" {
  description = "(Optional) Specified the VPC name."
  type        = string
  default     = "my-vpc"
}

variable "subnet_name" {
  description = "(Optional) Specified the VPC name."
  type        = string
  default     = "my-subnet"
}

variable "cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.1.0/24"
}

variable "region" {
  description = "(Optional) Specified the region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "(Optional) Specified the zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_type" {
    description = "(Optional) Specified the instance type"
    type        = string
    default     = "e2-micro"
}

variable "instance_name" {
    description = "(Optional) Specified the instance name"
    type        = string
    default     = "my-instance"
}

variable "boot_image" {
    description = "(Optional) Specified the boot image"
    type        = string
    default     = "debian-cloud/debian-11"
}

variable "project_id" {
    description = "(Required) Specified the project id"
    type        = string
}
