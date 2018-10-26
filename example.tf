variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "ami_id" {}
variable "db_user" {}
variable "db_password" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "web1" {
  ami           = "${var.ami_id}"
  instance_type = "t3.small"
}

resource "aws_instance" "web2" {
  ami           = "${var.ami_id}"
  instance_type = "t3.small"
}

resource "aws_elb" "loadbalancer" {
  name               = "loadbalancer-elb"
  availability_zones = ["us-east-1a"]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                   = ["${aws_instance.web1.id}", "${aws_instance.web2.id}"]
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_db_instance" "db1" {
  allocated_storage   = 20                   # https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "10.5"               # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.version105
  instance_class      = "db.t2.micro"
  name                = "usc_db1"
  username            = "${var.db_user}"
  password            = "${var.db_password}"
  skip_final_snapshot = true
}
