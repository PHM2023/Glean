variable "vpc_id" {
  type        = string
  description = "Id of the VPC within which the subnet is created"
}


variable "subnet_cidr" {
  type        = string
  description = "CIDR range of the subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone of the subnet"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
}

variable "route_table_id" {
  type        = string
  description = "Route table ID"
}

variable "region" {
  type        = string
  description = "Region to use when setting up vpc endpoints"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to add to the subnet"
  default     = {}
}