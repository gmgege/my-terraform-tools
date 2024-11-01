# Create Elastic IP for Bastion Host
resource "aws_eip" "bastion_eip" {
  count = var.enable_bastion_eip ? var.bastion_instance_count : 0

  depends_on = [module.ec2_public, module.vpc]
  tags = merge(
    local.common_tags,
    {
      Name = "BastionHost-EIP-${count.index + 1}"
    }
  )

  instance = module.ec2_public[count.index].id
  domain   = "vpc"

  ## Local Exec Provisioner:  local-exec provisioner (Destroy-Time Provisioner - Triggered during deletion of Resource)
  provisioner "local-exec" {
    command     = "echo Destroy time prov `date` >> destroy-time-prov.txt"
    working_dir = "local-exec-output-files/"
    when        = destroy
  }
}
