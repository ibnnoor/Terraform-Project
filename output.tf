#Generating Output variables
output "public-ip-01" {
  value = aws_instance.instance-01.public_ip
}

output "public-ip-02" {
  value = aws_instance.instance-02.public_ip
}

output "public-ip-03" {
  value = aws_instance.instance-03.public_ip
}


output "load_balancer_arn" {
  value = aws_lb.project-lb.arn
}

output "load_balancer_dns" {
  value = aws_lb.project-lb.dns_name
}

output "load_balancer_zone_id" {
  value = aws_lb.project-lb.zone_id
}

# Saving the ip values on a local host-inventory file
resource "local_file" "host-inventory" {
  filename = var.filename
  content  = <<EOT
  ${aws_instance.instance-01.public_ip}
  ${aws_instance.instance-02.public_ip}
  ${aws_instance.instance-03.public_ip}
  EOT
}

