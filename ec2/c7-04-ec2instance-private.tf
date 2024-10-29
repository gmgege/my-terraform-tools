# AWS EC2 Instance Terraform Module
# EC2 Instances that will be created in VPC Private Subnets
module "ec2_private" {
  depends_on = [module.vpc, aws_key_pair.my_key]
  source     = "terraform-aws-modules/ec2-instance/aws"
  version    = "5.6.0"

  name          = "${var.environment}-PrivateHost"
  ami           = data.aws_ami.ubuntulinux.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  user_data     = file("${path.module}/app1-install.sh")
  tags          = local.common_tags

  vpc_security_group_ids = [module.private_sg.security_group_id]
  for_each = {
    for idx in range(var.private_instance_count) : tostring(idx) => idx
  }
  subnet_id = element(module.vpc.private_subnets, tonumber(each.key))

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}


# ELEMENT Function
# terraform console 
# element(["kalyan", "reddy", "daida"], 0)
# element(["kalyan", "reddy", "daida"], 1)
# element(["kalyan", "reddy", "daida"], 2)

