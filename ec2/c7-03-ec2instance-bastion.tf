# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  count = var.bastion_instance_count

  name = "${var.environment}-BastionHost-${count.index + 1}"

  ami           = data.aws_ami.ubuntulinux.id
  instance_type = var.instance_type
  key_name      = var.bastion_key_name

  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.public_bastion_sg.security_group_id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device = [{
    volume_size           = 50    # 设置根卷大小为 50 GiB
    volume_type           = "gp3" # 设置 EBS 卷类型
    delete_on_termination = true
  }]

  ebs_block_device = [
    {
      device_name           = "/dev/nvme1n1"
      volume_size           = 200 # 设置附加卷大小为 100 GiB
      volume_type           = "gp3"
      delete_on_termination = false
    }
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-BastionHost-${count.index + 1}"
    }
  )
}

