variable "region" {
  default = "eu-north-1"
}

variable "ami_id" {
  default = "ami-0c1ac8a41498c1a9c"
}

variable "key_name" {
  description = "SSH key pair name to use for all EC2 instances"
  type        = string
}

variable "ndb_mgmd_instance_type" {
  default = "t3.micro"
}

variable "ndbmtd_count" {
  default = 2
}
variable "ndbmtd_instance_type" {
  default = "t3.xlarge"
}

variable "mysqld_count" {
  default = 2
}
variable "mysqld_instance_type" {
  default = "t3.xlarge"
}

variable "rdrs_count" {
  default = 2
}
variable "rdrs_instance_type" {
  default = "t3.xlarge"
}

variable "benchmark_count" {
  default = 2
}
variable "benchmark_instance_type" {
  default = "t3.xlarge"
}
