resource "aws_key_pair" "my_key" {
  key_name   = var.ssh_key_name
  public_key = file("${path.module}/${var.ssh_key_path}/my-key.pub")
  tags = {
    "Name"        = var.ssh_key_name
    "environment" = var.environment
    "owners"      = var.business_divsion
  }
}
