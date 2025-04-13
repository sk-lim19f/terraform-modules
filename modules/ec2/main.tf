resource "aws_instance" "ec2" {
  for_each = var.ec2_instance

  ami           = each.value.ami_name
  instance_type = each.value.instance_type
  key_name      = each.value.key_pair

  security_groups = each.value.ec2_security_groups
  subnet_id       = each.value.subnet_id

  iam_instance_profile = try(each.value.iam_instance_profile, null)

  credit_specification {
    cpu_credits = "standard"
  }

  ebs_block_device {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
  }

  tags = {
    Name = each.value.name
    Env  = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}
