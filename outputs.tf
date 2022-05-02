
output "aws_instance" {
  value = module.my-webserver.instance.public_ip
}
