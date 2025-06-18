variable "region" {
  default = "eu-north-1"
}

variable "cpu_platform" {
  default = "x86_64"
  description = "CPU platform (x86_64 or arm64_v8)"
  validation {
    condition     = contains(["x86_64", "arm64_v8"], var.cpu_platform)
    error_message = "cpu_platform must be either 'x86_64' or 'arm64_v8'"
  }
}

variable "num_azs" {
  default = 1
}


variable "key_name" {
  default = "rondb_bench_key"
}

variable "unique_suffix" {
  default = "123"
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


variable "prometheus_instance_type" {
  default = "t3.medium"
}
variable "prometheus_disk_size" {
  default = 120
}

variable "grafana_instance_type" {
  default = "t3.small"
}

variable "bench_count" {
  default = 2
}
variable "bench_instance_type" {
  default = "t3.xlarge"
}
variable "bench_disk_size" {
  default = 60
}
