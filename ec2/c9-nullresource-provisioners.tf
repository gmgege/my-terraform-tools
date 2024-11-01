# Create a Null Resource and Provisioners
resource "null_resource" "name" {
  depends_on = [module.ec2_public, module.ec2_public_instance]

  # 当 bastion_instance_count > 0 时使用堡垒机，否则使用公网实例
  connection {
    type = "ssh"
    host = (
      var.bastion_instance_count > 0 ? (
        var.enable_bastion_eip ? aws_eip.bastion_eip[0].public_ip : module.ec2_public[0].public_ip
        ) : (
        module.ec2_public_instance[0].public_ip
      )
    )
    user        = "ubuntu"
    password    = ""
    private_key = file("${path.module}/${var.ssh_key_path}/${var.ssh_key_name}.pem")
  }

  # 简化 count 逻辑，只在有实例时创建
  count = var.bastion_instance_count > 0 ? 1 : (var.public_instance_count > 0 ? 1 : 0)

  ## File Provisioner: Copies the terraform-key.pem file to /tmp/terraform-key.pem
  provisioner "file" {
    source      = "${path.module}/${var.ssh_key_path}/${var.ssh_key_name}.pem"
    destination = "/tmp/${var.ssh_key_name}.pem"
  }

  ## Remote Exec Provisioner: Using remote-exec provisioner fix the private key permissions on Bastion Host
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /tmp/${var.ssh_key_name}.pem"
    ]
  }

  ## Local Exec Provisioner: Creation-Time Provisioner
  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC ID: ${module.vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "local-exec-output-files/"
  }
}

# 输出连接信息
output "connection_host" {
  description = "The host being used for SSH connection"
  value = (
    var.bastion_instance_count > 0 ? (
      var.enable_bastion_eip ? aws_eip.bastion_eip[0].public_ip : module.ec2_public[0].public_ip
      ) : (
      var.public_instance_count > 0 ? (
        "Using public instance: ${module.ec2_public_instance[0].public_ip}"
      ) : "No available public IP for connection"
    )
  )
}
