variable "name" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "region" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "private_subnet_ids" {}
variable "public_subnet_ids" {}
variable "elasticsearch_endpoint" {}

variable "bastion_instance_type" {}
variable "key_name" {}

module "bastion" {
  source = "./bastion"

  name              = "${var.name}-bastion"
  vpc_id            = "${var.vpc_id}"
  vpc_cidr          = "${var.vpc_cidr}"
  region            = "${var.region}"
  public_subnet_ids = "${var.public_subnet_ids}"
  key_name          = "${var.key_name}"
  instance_type     = "${var.bastion_instance_type}"
  key_name          = "${var.key_name}"
}

resource "aws_elastic_beanstalk_application" "web" {
  name = "${var.name}-kuronometer-eb-app"
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
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }

  # Instances 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.private_subnet_ids}"
  }

  # ELB 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${var.public_subnet_ids}"
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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ELASTIC_URL"
    value     = "https://${var.elasticsearch_endpoint}/"
  }
}
