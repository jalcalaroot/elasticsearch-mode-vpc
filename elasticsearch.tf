#-----------------------------------------------------------
#SG
resource "aws_security_group" "elastic-sg" {
  name = "${var.elastic_search_name}-sg"
  description = "${var.elastic_search_name}-sg"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# 9200
  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
# 9300
  ingress {
    from_port = 9300
    to_port = 9300
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${var.elastic_search_name}-sg"
    env  = "terraform"
  }
}
#---------------------------------------------------------
resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}
#----------------------------------------------------------
resource "aws_elasticsearch_domain" "main" {
  domain_name = "${var.elastic_search_name}"
  elasticsearch_version = "7.4"

  cluster_config {
    instance_type = "${var.instance_type}"
    instance_count = "1"
    dedicated_master_enabled = "false"
    zone_awareness_enabled = "false"
  }



  vpc_options {
    security_group_ids = ["${aws_security_group.elastic-sg.id}"]
    subnet_ids = ["${var.subnetid_1}"]
  }


  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }
    access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:${var.region}:${var.id_account}:domain/${var.elastic_search_name}/*"
    }
  ]
}
CONFIG

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }

  depends_on = [
    "aws_iam_service_linked_role.es",
  ]
}
