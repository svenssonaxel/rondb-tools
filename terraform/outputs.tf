output "ndb_mgmd_public_ip" {
  value = aws_instance.ndb_mgmd[0].public_ip
}

output "ndb_mgmd_private_ip" {
  value = aws_instance.ndb_mgmd[0].private_ip
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

output "benchmark_public_ips" {
  value = [for inst in aws_instance.benchmark : inst.public_ip]
}

output "benchmark_private_ips" {
  value = [for inst in aws_instance.benchmark : inst.private_ip]
}

output "rdrs_nlb_dns" {
  value = aws_lb.rdrs_nlb.dns_name
}

output "rondis_nlb_dns" {
  value = aws_lb.rondis_nlb.dns_name
}

output "rondb_replicas" {
  value = var.rondb_replicas
}

output "cpu_platform" {
  value = var.cpu_platform
}

output "rondb_version" {
  value = var.rondb_version
}

output "num_azs" {
  value = var.num_azs
}
