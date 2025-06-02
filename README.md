## Configure
Optionally, edit `terraform.tfvars` to your liking.

## Startup
1. Run `nix-shell` **or** install the following dependencies:
  * awscli
  * python3
  * rsync
  * terraform
  * tmux
2. Configure AWS
  ```
  aws configure
  ./create_aws_ssh_key
  ```
3. Initialize terraform
  ```
  terraform init
  ```

## Deploy
1. Create terraform cluster.
  ```
  terraform apply && terraform output -json > tf_output
  ```
2. Deploy RonDB cluster
  ```
  ./cluster_ctl deploy
  ```
3. Start services
  ```
  ./cluster_ctl start
  ```
  A web address will be printed that allows you to monitor the cluster using a grafana dashboard.

If you later want to stop services, use `./cluster_ctl stop`.

If you want to change the cluster configuration, it is enough to edit `terraform.tfvars` and then redo the steps in this *Deploy* section.

## Run benchmarks

### Locust

1. Populate benchmark table
  ```
  ./cluster_ctl populate 100 1000000 INT
  ```
  You may choose different parameters, run `./cluster_ctl` for usage.
2. Start locust
  ```
  ./cluster_ctl start_locust
  ```
3. Use the web address printed to run the benchmark.
   If you changed the number of rows in step 1, you must now enter it under *Custom parameters* -> *Table Size*.
4. During the benchmark run, you can use both locust and grafana to gather statistics, from the client's and server's point of view, respectively.
5. Stop locust
  ```
  ./cluster_ctl stop_locust
  ```

## Manual cluster access
Run `./cluster_ctl open_tmux` to create or reattach to a *tmux* session with *ssh* connections opened to all nodes.

## Cleanup
Running `./cleanup` will destroy the terraform cluster, delete the AWS SSH key, delete temporary files and remove the tmux session.
