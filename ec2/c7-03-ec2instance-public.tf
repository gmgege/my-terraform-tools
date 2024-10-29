# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public_instance" {
  depends_on = [module.vpc, aws_key_pair.my_key]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "5.6.0"

  count = var.public_instance_count

  name                   = "${var.environment}-PublicHost-${count.index + 1}"
  ami                    = data.aws_ami.ubuntulinux.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  user_data              = file("${path.module}/app1-install.sh")
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.public_instance_sg.security_group_id]
  tags                   = local.common_tags

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

