# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
module "ec2_public" {
  depends_on = [module.vpc, aws_key_pair.my_key]
  source     = "terraform-aws-modules/ec2-instance/aws"
  #version = "2.17.0"
  version = "5.6.0"
  # insert the 10 required variables here
  name = "${var.environment}-BastionHost"
  #instance_count         = 5
  ami           = data.aws_ami.ubuntulinux.id
  instance_type = var.instance_type
  key_name      = var.bastion_key_name
  #monitoring             = true
  subnet_id = module.vpc.public_subnets[0]
  #vpc_security_group_ids = [module.public_bastion_sg.this_security_group_id]
  vpc_security_group_ids = [module.public_bastion_sg.security_group_id]
  tags                   = local.common_tags

  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true
}

