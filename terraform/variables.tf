variable "region" {
  default = "eu-north-1"
}

variable "rondb_replicas" {
  default = 2
}

variable "rondb_version" {
  default = "24.10.1"
}

variable "cpu_platform" {
  default = "x86_64"
}

variable "num_azs" {
  default = 1
}

variable "ami_id" {
  default = "ami-09fdd0b7882a4ec7b"
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

variable "ndbmtd_disk_size" {
  default = 200
}

variable "mysqld_count" {
  default = 2
}
variable "mysqld_instance_type" {
  default = "t3.xlarge"
}

variable "mysqld_disk_size" {
  default = 60
}

variable "rdrs_count" {
  default = 2
}
variable "rdrs_instance_type" {
  default = "t3.xlarge"
}

variable "rdrs_disk_size" {
  default = 60
}

variable "benchmark_count" {
  default = 2
}
variable "benchmark_instance_type" {
  default = "t3.xlarge"
}

variable "benchmark_disk_size" {
  default = 60
}
