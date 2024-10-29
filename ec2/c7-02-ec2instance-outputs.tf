# AWS EC2 Instance Terraform Outputs
# Public EC2 Instances - Bastion Host


# Instance Details Output
output "private_instance_details" {
  value = {
    # Private Instances
    for idx, instance in module.ec2_private :
    "Private-Host-${idx + 1}" => {
      id         = instance.id
      public_ip  = ""
      private_ip = instance.private_ip
      region     = var.aws_region
      ssh_command = var.enable_ssh ? (
        module.ec2_public.public_ip != "" ?
        <<-EOF
        ssh -i ${var.ssh_key_path}/${var.ssh_key_name}.pem -o "ProxyCommand ssh -i ${var.bastion_key_path}/${var.bastion_key_name}.pem -W %h:%p ubuntu@${var.enable_bastion_eip ? aws_eip.bastion_eip[0].public_ip : module.ec2_public.public_ip}" ubuntu@${instance.private_ip}
        EOF
        :
        "Bastion host not available"
      ) : "SSH not enabled"
      ssm_command = var.enable_ssm ? "aws ssm start-session --target ${instance.id} --region ${var.aws_region}" : "SSM not enabled"
    }
  }
}

# Public Instances Output
output "public_instance_details" {
  value = {
    for idx, instance in module.ec2_public_instance :
    "${var.environment}-PublicHost-${idx + 1}" => {
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      region     = var.aws_region
      ssh_command = var.enable_ssh ? (
        "ssh -i ${var.ssh_key_name}.pem ubuntu@${instance.public_ip}"
      ) : "SSH not enabled"
      ssm_command = var.enable_ssm ? "aws ssm start-session --target ${instance.id} --region ${var.aws_region}" : "SSM not enabled"
    }
  }
}

# Bastion Host Details Output
output "bastion_details" {
  value = {
    id         = module.ec2_public.id
    public_ip  = var.enable_bastion_eip ? aws_eip.bastion_eip[0].public_ip : module.ec2_public.public_ip
    private_ip = module.ec2_public.private_ip
    region     = var.aws_region
    ssh_command = var.enable_ssh ? (
      "ssh -i ${var.ssh_key_name}.pem ubuntu@${var.enable_bastion_eip ? aws_eip.bastion_eip[0].public_ip : module.ec2_public.public_ip}"
    ) : "SSH not enabled"
    ssm_command = var.enable_ssm ? "aws ssm start-session --target ${module.ec2_public.id} --region ${var.aws_region}" : "SSM not enabled"
  }
}




