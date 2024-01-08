resource "aws_sns_topic" "ec2-alarm" {
  name   = "${var.project_name}-${var.project_environment}-ec2-alarm"
}

resource "aws_sns_topic_subscription" "ec2-alarm_email_target" {
  topic_arn = aws_sns_topic.ec2-alarm.arn
  protocol  = "email"
  endpoint  = "alerts@tenforwardconsulting.com"
}
