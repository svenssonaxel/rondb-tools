key_name = "REPLACE_ME_with_the_key_name_(without .pem extension)_of_your_XXX.pem file"
region = "eu-north-1"

# ami_id is the OS image, different based on region and HW
# default is arm64_v8 in eu-north-1
#ami_id = "ami-0c1ac8a41498c1a9c"

# Set this variable to true if you want to set up a multi-AZ
# installation. num_azs is also available if number of AZs isn't
# equal to 3.
#use_multiple_azs = true
#num_azs = 3

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
