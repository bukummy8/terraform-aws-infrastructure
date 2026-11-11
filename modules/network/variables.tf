
variable "name" {
  description = "Name prefix for network resources"
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The network name must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required."
  }

  validation {
    condition = (
      length(distinct(var.availability_zones)) ==
      length(var.availability_zones)
    )
    error_message = "Availability zones must be unique."
  }
}

variable "public_subnet_cidrs" {
  description = "IPv4 CIDR blocks for public subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_cidrs) ==
      length(var.availability_zones)
    )
    error_message = "The number of public subnet CIDRs must match the number of availability zones."
  }

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "IPv4 CIDR blocks for private subnets"
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_cidrs) ==
      length(var.availability_zones)
    )
    error_message = "The number of private subnet CIDRs must match the number of availability zones."
  }

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))
    ])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "tags" {
  description = "Additional tags to apply to network resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)"
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )
    error_message = "Environment must be dev, staging, or production."
  }
}
