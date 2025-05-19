key_name = "REPLACE_ME_with_the_key_name_(without .pem extension)_of_your_XXX.pem file"
region = "eu-north-1"

# ami_id is the OS image, different based on region and HW
# default is arm64_v8 in eu-north-1
#ami_id = "ami-0c1ac8a41498c1a9c"

# Set this variable to number of AZs to use, number larger than
# 1 means multi-AZ environment and 1 means single-AZ. Defaults to 1.
num_azs = 2

#CPU platform used by the VMs, can currently have 1 at a time and
#choice is between the default x86_64 and arm64_v8.
cpu_platform = "arm64_v8"

#When creating installation script we need to know which RonDB version
#to use. Defaults to "24.10.1".
rondb_version = "24.10.1"

#When creating config.ini we need to set number of replicas in RonDB.
#Defaults to 2, number of ndbmtd_count must be a multiple of this
#number.
rondb_replicas = 2

ndb_mgmd_instance_type = "c8g.medium"
ndbmtd_count = 2
ndbmtd_instance_type = "c8g.xlarge"
#ndbmtd_instance_type = "c7a.8xlarge"
mysqld_count = 1
#mysqld_instance_type = "t3.2xlarge"
mysqld_instance_type = "c8g.large"
rdrs_count = 3
rdrs_instance_type = "c8g.xlarge"
#rdrs_instance_type = "c7a.4xlarge"
benchmark_count = 1
benchmark_instance_type = "c8g.xlarge"
#benchmark_instance_type = "c7a.8xlarge"
