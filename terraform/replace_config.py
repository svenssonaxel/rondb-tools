from string import Template

def format_host_block(name, pub_ips, pri_ips):
    lines = [f"{name}_NUMS={len(pub_ips)}"]
    for i, (pri, pub) in enumerate(zip(pri_ips, pub_ips), 1):
        lines.append(f"{name}_PRI_{i}={pri}")
        lines.append(f"{name}_PUB_{i}={pub}")
    return "\n".join(lines)

def generate_config(tf_output, var_constants, ip_data, key_name="your-key-name"):
    template = Template("""#!/bin/bash
USER=ubuntu
WORKSPACE=/home/$${USER}/workspace
RUN_DIR=$${WORKSPACE}/rondb-run
KEY_PEM=${key_name}.pem

TARBALL_NAME=rondb-${rondb_version}-linux-glibc2.28-${cpu_platform}.tar.gz
NUM_AZS=${num_azs}

NDB_MGMD_PRI=${ndb_mgmd_pri}
NDB_MGMD_PUB=${ndb_mgmd_pub}

NO_OF_REPLICAS=${rondb_replicas}
${ndbmtd_block}

${mysqld_block}

RDRS_LB="http://${rdrs_lb}:4406"
RONDIS_LB="${rondis_lb}:6379"
${rdrs_block}

${benchmark_block}

VALKEY_NUMS=$$LOC_NUMS
VAL_PRI_1=$$LOC_PRI_1
VAL_PUB_1=$$LOC_PUB_1
VAL_PRI_2=$$LOC_PRI_2
VAL_PUB_2=$$LOC_PUB_2
""")

    return template.substitute(
        key_name=key_name,
        rondb_replicas=var_constants["rondb_replicas"],
        cpu_platform=var_constants["cpu_platform"],
        num_azs=var_constants["num_azs"],
        rondb_version=var_constants["rondb_version"],
        ndb_mgmd_pri=ip_data["ndb_mgmd"]["private"],
        ndb_mgmd_pub=ip_data["ndb_mgmd"]["public"],
        ndbmtd_block=format_host_block("NDBMTD", ip_data["ndbmtd"]["public"], ip_data["ndbmtd"]["private"]),
        mysqld_block=format_host_block("MYSQLD", ip_data["mysqld"]["public"], ip_data["mysqld"]["private"]),
        rdrs_block=format_host_block("RDRS", ip_data["rdrs"]["public"], ip_data["rdrs"]["private"]),
        benchmark_block=format_host_block("LOC", ip_data["benchmark"]["public"], ip_data["benchmark"]["private"]),
        rdrs_lb=tf_output["rdrs_nlb_dns"]["value"],
        rondis_lb=tf_output["rondis_nlb_dns"]["value"]
    )

