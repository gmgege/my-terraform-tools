# AWS EC2 Instance Terraform Variables
# EC2 Instance Variables

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

# AWS EC2 Private Instance Count
variable "private_instance_count" {
  description = "AWS EC2 Private Instances Count"
  type        = number
  default     = 1
}

# AWS EC2 Public Instance Count
variable "public_instance_count" {
  description = "AWS EC2 Public Instances Count"
  type        = number
  default     = 1
}

# SSH 和 SSM 配置变量
variable "enable_ssh" {
  description = "Enable SSH access for EC2 instances"
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Enable SSM access for EC2 instances"
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "SSH key name"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to SSH key directory"
  type        = string
}

variable "bastion_key_name" {
  description = "SSH key name for bastion host"
  type        = string
  default     = "my-key"
}

variable "bastion_key_path" {
  description = "Path to the directory containing bastion SSH key file"
  type        = string
  default     = "private-key"
}

# EIP Configuration Variable
variable "enable_bastion_eip" {
  description = "Enable Elastic IP for Bastion Host"
  type        = bool
  default     = false
}
