variable "name"            { }
variable "vpc_cidr"        { }
variable "azs"             { }
variable "region"          { }
variable "private_subnets" { }
variable "public_subnets"  { }

resource "aws_elastic_beanstalk_application" "web" {
  name        = "${var.name}-kuronometer-eb-app"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "${var.name}-kuronometer-eb-env"
  application         = "${aws_elastic_beanstalk_application.web.name}"
  solution_stack_name = "64bit Amazon Linux 2017.03 v2.6.0 running Docker 1.12.6"

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
	value     = "aws-elasticbeanstalk-ec2-role"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Tue:10:00"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }
}
