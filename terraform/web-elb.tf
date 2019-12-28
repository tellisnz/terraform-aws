resource "aws_security_group" "elb_web" {
  name = format("%s-elb-web-sg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = var.web_port
    to_port   = var.web_port
    protocol  = "tcp"

    #    cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = ["39.109.189.92/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Group = var.name
    Name  = "web-elb-sg"
  }
}

module "elb_web" {
  source = "terraform-aws-modules/elb/aws"

  name = format("%s-elb-web", var.name)

  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.elb_web.id]
  internal        = false

  listener = [
    {
      instance_port     = var.web_port
      instance_protocol = "HTTP"
      lb_port           = var.web_port
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
      target              = "HTTP:${var.web_port}/"
      interval            = var.web_elb_health_check_interval
      healthy_threshold   = var.web_elb_healthy_threshold
      unhealthy_threshold = var.web_elb_unhealthy_threshold
      timeout             = var.web_elb_health_check_timeout
    }

  tags = {
    Group = var.name
    Name  = "web-elb-${var.name}"
  }
}

output "elb_dns_name" {
  value = module.elb_web.this_elb_dns_name
}
