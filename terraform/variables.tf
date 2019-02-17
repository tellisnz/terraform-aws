# region = "us-west-2"
# public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRQYYw42SeWm4SvTt4iipyjozdpaR5FlNeyo3oWYXF2W2Uur+XXJssFhxD8xf0NFKRtrK3wVZPkP/7k6+eRufC9Lq6VZvImlCTFJmEy+uHnA+vlkoXbUGk2zr7Cpct7udpZZxSivt+7lQ4avhBCQE/hw1qZxdGyZJY1Z1F3LGHCP55a+h5XxtaZR0eJQmejWnG9wq++iywdeOH2tCeOsnyNw1bjhYfydEDK7OAh/sZYsroxGpk/0SNFyscy/x2zEBrveDppE6QlH9pffx50mV00OgefHx2wpa95jwG7RWKvUkwqqMx1bEbg7tZ76PfNTM/rRg+EV9d1NMKQ3R5S1zT"
# name = "terraform-aws-three-tier"
variable "region" {
  default = "us-west-2"
}

variable "name" {
  default = "terraform-aws-three-tier"
}

variable "public_key"{
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRQYYw42SeWm4SvTt4iipyjozdpaR5FlNeyo3oWYXF2W2Uur+XXJssFhxD8xf0NFKRtrK3wVZPkP/7k6+eRufC9Lq6VZvImlCTFJmEy+uHnA+vlkoXbUGk2zr7Cpct7udpZZxSivt+7lQ4avhBCQE/hw1qZxdGyZJY1Z1F3LGHCP55a+h5XxtaZR0eJQmejWnG9wq++iywdeOH2tCeOsnyNw1bjhYfydEDK7OAh/sZYsroxGpk/0SNFyscy/x2zEBrveDppE6QlH9pffx50mV00OgefHx2wpa95jwG7RWKvUkwqqMx1bEbg7tZ76PfNTM/rRg+EV9d1NMKQ3R5S1zT"
}

# VPC Variables
variable "vpc_env" {
  description = "VPC environment"
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  default     = "10.7.0.0/16"
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  default     = [ "us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = ["10.7.1.0/24", "10.7.2.0/24", "10.7.3.0/24"]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = ["10.7.11.0/24", "10.7.12.0/24", "10.7.13.0/24"]
}

variable "vpc_database_subnets" {
  type        = "list"
  description = "A list of database subnets"
  default     = ["10.7.21.0/24", "10.7.22.0/24", "10.7.23.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  default     = true
}

# DB
variable "db_identifier" {
  description = "The name of the RDS instance"
  default = "terraformaws"
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB"
  default = 5
}

variable "db_name" {
  description = "The DB name to create"
  default = "taws"
}

variable "db_username" {
  description = "Username for the master DB user"
  default = "tawsdbuser"
}

variable "db_password" {
  description = "Password for the master DB user"
  default = "tawsdbpassword"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  default = 5432
}

variable "db_maintenance_window" {
  description = "The window to perform maintenance in"
  default = "Mon:00:00-Mon:03:00"
}

variable "db_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled"
  default = "03:00-06:00"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups for"
  default = 0
}

variable "db_engine" {
  description = "DB engine"
  default = "postgres"
}

variable "db_engine_version" {
  description = "DB engine version"
  default = "9.6.11"
}

variable "db_family" {
  description = "DB family"
  default = "postgres9.6"
}

variable "db_instance_class" {
  description = "DB instance class"
  default = "db.t2.micro"
}

#db_allocated_storage =
#db_port =
#db_backup_window =
#db_backup_retention_period =
#db_maintenance_window =

#app_port =
#app_instance_type =
#app_autoscale_min_size =
#app_autoscale_max_size =
#app_elb_health_check_interval =
#app_elb_healthy_threshold =
#app_elb_unhealthy_threshold =
#app_elb_health_check_timeout =

#web_port =
#web_instance_type =
#web_autoscale_min_size =
#web_autoscale_max_size =
#web_elb_health_check_interval =
#web_elb_healthy_threshold =
#web_elb_unhealthy_threshold =
#web_elb_health_check_timeout =
