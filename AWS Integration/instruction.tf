provider "aws" {
  region = "aws_region"
}

resource "aws_s3_bucket" "terraform_backend" {
  bucket = " bucket-name"
  acl    = "private"
  versioning {
    enabled = true
  }
}
terraform {
  backend "s3" {
    bucket         = "bucket-name"
    key            = "path/to/your/terraform.tfstate"
    region         = "aws_region"
    encrypt        = true
    dynamodb_table = "terraform_locks"
  }
}
provider "aws" {
  region = "aws_region"
}

resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "ExampleAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors EC2 CPU utilization."

  dimensions = {
    InstanceId = "instance_id"
  }

  alarm_actions = ["arn:aws:sns:your_aws_region:your_account_id:YourSNSTopic"]
}
