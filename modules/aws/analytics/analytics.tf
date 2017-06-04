variable "name"           		  { }
variable "nat_gateway_public_ips" { type = "list" }

resource "aws_elasticsearch_domain" "kuronometer" {
  domain_name           = "${var.name}-kuronometer"
  elasticsearch_version = "5.3"
  cluster_config {
    instance_type = "t2.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
	ebs_enabled = true
	volume_size = 35  	
  }
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = "${aws_elasticsearch_domain.kuronometer.domain_name}"

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ${jsonencode(var.nat_gateway_public_ips)}
        }
      },
      "Resource": "${aws_elasticsearch_domain.kuronometer.arn}/*"
    }
  ]
}
POLICIES
}

output "elasticsearch_endpoint" {
  value = "${aws_elasticsearch_domain.kuronometer.endpoint}"
}