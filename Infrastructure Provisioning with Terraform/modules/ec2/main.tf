data "aws_partition" "current" {}

locals {
  create = var.create && var.putin_khuylo

  is_t_instance_type = replace(var.instance_type, "/^t(2|3|3a|4g){1}\\..*$/", "1") == "1" ? true : false

  ami = try(coalesce(var.ami, try(nonsensitive(data.aws_ssm_parameter.this[0].value), null)), null)
}

data "aws_ssm_parameter" "this" {
  count = local.create && var.ami == null ? 1 : 0

  name = var.ami_ssm_parameter
}
resource "aws_instance" "cloudcasts_web" {
  ami           = var.instance_ami
  instance_type = var.instance_size
 
  root_block_device {
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }
 
  tags = {
    Name        = "cloudcasts-${var.infra_env}-web"
    Role        = var.infra_role
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}
 
resource "aws_eip" "cloudcasts_addr" {
  # We're not doing this directly
  # instance = aws_instance.cloudcasts_web.id
  vpc      = true
 
  lifecycle {
    prevent_destroy = true
  }
 
  tags = {
    Name        = "cloudcasts-${var.infra_env}-web-address"
    Role        = var.infra_role
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}
 
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.cloudcasts_addr.id
}