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

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-BastionHost-${count.index + 1}"
    }
  )
}

