resource "aws_security_group" "elb_app" {
  name = "${format("%s-elb-app-sg", var.name)}"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Group = "${var.name}"
  }

}

module "elb_app" {
  source = "terraform-aws-modules/elb/aws"

  name = "${format("%s-elb-app", var.name)}"

  subnets         = ["${module.vpc.private_subnets}"]
  security_groups = ["${aws_security_group.elb_app.id}"]
  internal        = true

  listener = [
    {
      instance_port     = "${var.app_port}"
      instance_protocol = "TCP"
      lb_port           = "${var.app_port}"
      lb_protocol       = "TCP"
    },
  ]

  health_check = [
    {
      target              = "TCP:${var.app_port}"
      interval            = "${var.app_elb_health_check_interval}"
      healthy_threshold   = "${var.app_elb_healthy_threshold}"
      unhealthy_threshold = "${var.app_elb_unhealthy_threshold}"
      timeout             = "${var.app_elb_health_check_timeout}"
    },
  ]

  tags {
    Group = "${var.name}"
  }

}

variable "app_elb_health_check_interval" {
  description = "Duration between health checks"
  default = 20
}

variable "app_elb_healthy_threshold" {
  description = "Number of checks before an instance is declared healthy"
  default = 2
}

variable "app_elb_unhealthy_threshold" {
  description = "Number of checks before an instance is declared unhealthy"
  default = 2
}

variable "app_elb_health_check_timeout" {
  description = "Interval between checks"
  default = 5
}

