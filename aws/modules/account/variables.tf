variable "account_owner_email" {
  description = "Email address of the owner to assign to the new member account"
  type        = string
}

variable "account_name" {
  description = "Friendly name for the member account"
  type        = string
}

variable "region" {
  description = "The region in which the api calls made for management account"
  type        = string
  default     = "us-east-1"
}

