#!/bin/bash
terraform output -json > ./tf_output.json
key_name=$(grep '^key_name' ./terraform.tfvars | sed -E 's/^key_name *= *"(.*)"/\1/')
python3 write2config.py "$key_name"
