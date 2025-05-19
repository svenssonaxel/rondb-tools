from replace_config import generate_config
import json
import sys

if len(sys.argv) < 2:
    print("Usage: python3 write2config.py <key_name>")
    sys.exit(1)

key_name_str = sys.argv[1]

with open("tf_output.json") as f:
    tf_output = json.load(f)

ip_data = {
    "ndb_mgmd": {
        "private": tf_output["ndb_mgmd_private_ip"]["value"],
        "public": tf_output["ndb_mgmd_public_ip"]["value"]
    },
    "ndbmtd": {
        "private": tf_output["ndbmtd_private_ips"]["value"],
        "public": tf_output["ndbmtd_public_ips"]["value"]
    },
    "mysqld": {
        "private": tf_output["mysqld_private_ips"]["value"],
        "public": tf_output["mysqld_public_ips"]["value"]
    },
    "rdrs": {
        "private": tf_output["rdrs_private_ips"]["value"],
        "public": tf_output["rdrs_public_ips"]["value"]
    },
    "benchmark": {
        "private": tf_output["benchmark_private_ips"]["value"],
        "public": tf_output["benchmark_public_ips"]["value"]
    }
}

var_constants = {
    "rondb_replicas": tf_output["rondb_replicas"]["value"],
    "cpu_platform": tf_output["cpu_platform"]["value"],
    "num_azs": tf_output["num_azs"]["value"],
    "rondb_version": tf_output["rondb_version"]["value"]
}

config = generate_config(tf_output, var_constants, ip_data, key_name=key_name_str)
with open("config", "w") as f:
    f.write(config)
print("config file generated")

