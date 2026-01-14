output "elastic_ip" {
  value = aws_eip.k3s_eip.public_ip
}

output "ssh_command" {
  value = "ssh ubuntu@${aws_eip.k3s_eip.public_ip}"
}

output "hosted_zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "hosted_zone_name_servers" {
  value = aws_route53_zone.this.name_servers
}
