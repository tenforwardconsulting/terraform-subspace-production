resource "aws_instance" "worker" {
  count                  = var.worker_instance_count
  ami                    = var.instance_ami
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.subspace.key_name
  subnet_id              = data.aws_subnets.subnets.ids[count.index % length(data.aws_subnets.subnets)]
  vpc_security_group_ids = [aws_security_group.production-webservers.id, aws_security_group.production-internal.id]
  monitoring             = true

  root_block_device {
    volume_size = var.worker_volume_size
    encrypted = true
    kms_key_id = aws_kms_key.subspace.arn
  }

  tags = {
    Name = "${var.project_environment}-worker${count.index+1}"
  }
}

# Associate an elastic IP with each worker server
resource aws_eip "worker" {
  count   = var.worker_instance_count
  instance = aws_instance.worker[count.index].id

  tags = {
    Name = "${var.project_environment}-worker${count.index+1}"
  }
}

resource "aws_eip_association" "worker_eip_assoc" {
  count = var.worker_instance_count
  instance_id   = aws_instance.worker[count.index].id
  allocation_id = aws_eip.worker[count.index].id
}

resource "aws_cloudwatch_metric_alarm" "worker" {
  count                     = var.worker_instance_count
  alarm_name                = "${var.project_name}-${var.project_environment}-worker-status-${aws_instance.worker[count.index].id}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  alarm_description         = "This metric monitors both EC2 instance and system status"
  insufficient_data_actions = []
  dimensions = {
    InstanceId = "${aws_instance.worker[count.index].id}"
  }
}
