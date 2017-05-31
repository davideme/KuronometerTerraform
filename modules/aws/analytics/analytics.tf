variable "name"           		  { }
variable "nat_gateway_public_ips" { type = "list" }

resource "aws_elasticsearch_domain" "kuronometer" {
  domain_name           = "${var.name}-kuronometer"
  elasticsearch_version = "5.1"
  cluster_config {
    instance_type = "t2.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
	ebs_enabled = true
	volume_size = 35  	
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ${jsonencode(var.nat_gateway_public_ips)}}
            }
        }
    ]
}
CONFIG
}
