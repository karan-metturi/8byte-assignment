# ---------------------------
# VPC / Subnet Variables
# ---------------------------
variable "vpc_cidr" {
  description = "CIDR block for main VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ---------------------------
# Database Variables
# ---------------------------
variable "db_name" {
  default = "appdb"
}

variable "db_username" {
  default = "postgres"
}

variable "db_password" {
  description = "DB password"
  type        = string
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 20
}

# ---------------------------
# Region
# ---------------------------
variable "region" {
  default = "ap-south-1"
}
