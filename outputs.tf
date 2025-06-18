output "ndb_mgmd_public_ips" {
  value = [for inst in aws_instance.ndb_mgmd : inst.public_ip]
}

output "ndb_mgmd_private_ips" {
  value = [for inst in aws_instance.ndb_mgmd : inst.private_ip]
}

output "ndbmtd_public_ips" {
  value = [for inst in aws_instance.ndbmtd : inst.public_ip]
}

output "ndbmtd_private_ips" {
  value = [for inst in aws_instance.ndbmtd : inst.private_ip]
}

output "mysqld_public_ips" {
  value = [for inst in aws_instance.mysqld : inst.public_ip]
}

output "mysqld_private_ips" {
  value = [for inst in aws_instance.mysqld : inst.private_ip]
}

output "rdrs_public_ips" {
  value = [for inst in aws_instance.rdrs : inst.public_ip]
}

output "rdrs_private_ips" {
  value = [for inst in aws_instance.rdrs : inst.private_ip]
}

output "prometheus_public_ips" {
  value = [for inst in aws_instance.prometheus : inst.public_ip]
}

output "prometheus_private_ips" {
  value = [for inst in aws_instance.prometheus : inst.private_ip]
}

output "grafana_public_ips" {
  value = [for inst in aws_instance.grafana : inst.public_ip]
}

output "grafana_private_ips" {
  value = [for inst in aws_instance.grafana : inst.private_ip]
}

output "bench_public_ips" {
  value = [for inst in aws_instance.bench : inst.public_ip]
}

output "bench_private_ips" {
  value = [for inst in aws_instance.bench : inst.private_ip]
}

output "bench_cpus_per_node" {
  value = data.aws_ec2_instance_type.bench_type.default_vcpus
}

output "rdrs_nlb_dns" {
  value = aws_lb.rdrs_nlb.dns_name
}

output "rondis_nlb_dns" {
  value = aws_lb.rondis_nlb.dns_name
}
