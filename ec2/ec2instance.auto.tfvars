# EC2 Instance Variables
instance_type          = "t2.micro"
private_instance_count = 1
public_instance_count  = 1

# SSH Key Configuration
ssh_key_name     = "my-key"
ssh_key_path     = "private-key"
bastion_key_name = "my-key"
bastion_key_path = "private-key"

# EIP Configuration
enable_bastion_eip = true # 控制是否为 bastion 创建 EIP
