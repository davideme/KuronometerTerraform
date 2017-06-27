variable "name" {}
variable "region" {}

variable "vpc_cidr" {}
variable "azs" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "key_name" {}

variable "bastion_instance_type" {}

provider "aws" {
  region = "${var.region}"
}

# Network

module "network" {
  source = "../../../modules/aws/network"

  name            = "${var.name}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  region          = "${var.region}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
}

# Compute

module "compute" {
  source = "../../../modules/aws/compute"

  name                   = "${var.name}"
  region                 = "${var.region}"
  vpc_cidr               = "${var.vpc_cidr}"
  vpc_id                 = "${module.network.vpc_id}"
  azs                    = "${var.azs}"
  private_subnets        = "${var.private_subnets}"
  public_subnets         = "${var.public_subnets}"
  private_subnet_ids     = "${module.network.private_subnet_ids}"
  public_subnet_ids      = "${module.network.public_subnet_ids}"
  elasticsearch_endpoint = "${module.analytics.elasticsearch_endpoint}"

  bastion_instance_type = "${var.bastion_instance_type}"
  key_name              = "${var.key_name}"
}

# Analytics

module "analytics" {
  source = "../../../modules/aws/analytics"

  name                   = "${var.name}"
  nat_gateway_public_ips = "${module.network.nat_gateway_public_ips}"
}
