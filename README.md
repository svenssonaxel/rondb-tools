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
  terraform apply
  ```
2. Deploy RonDB cluster
  ```
  ./cluster_ctl deploy
  ```
  A web address will be printed that allows you to monitor the cluster using a grafana dashboard.

If you want to change the cluster configuration, it is enough to edit `terraform.tfvars` and then redo the steps in this *Deploy* section.

## Run benchmarks

### Locust

1. Create test data and start locust
  ```
  ./cluster_ctl bench_locust
  ```
2. Use the web address printed to run the benchmark.

During the benchmark run, you can use both locust and grafana to gather statistics, from the client's and server's point of view, respectively.

If you want different parameters for the test data just redo the steps above; run `./cluster_ctl` for usage.

To restart with different parameters, simply redo the steps above.

## Manual cluster access
Run `./cluster_ctl open_tmux` to open a *tmux* session with one window accessing each node.

## Cleanup
Running `./cleanup` will destroy the terraform cluster, delete the AWS SSH key, delete temporary files and remove the tmux session.
