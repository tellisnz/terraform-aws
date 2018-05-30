resource "aws_security_group" "web" {
  name = "${format("%s-web-sg", var.name)}"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.web_port}"
    to_port     = "${var.web_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Group = "${var.name}"
  }

}

#TODO REMOVE
resource "aws_key_pair" "web-key" {
  key_name = "web-key"
  public_key = "${var.public_key}"

}

resource "aws_launch_configuration" "web" {
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "${var.web_instance_type}"
  security_groups = ["${aws_security_group.web.id}"]
  #TODO REMOVE
  key_name = "web-key"
  name_prefix = "${var.name}-web-vm-"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y git gettext
              curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
              . ~/.nvm/nvm.sh
              nvm install 6.11.5
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/client
              export APP_ELB="${module.elb_web.this_elb_dns_name}" APP_PORT="${var.app_port}" WEB_PORT ="${var.web_port}"
              envsubst '${APP_PORT} ${APP_ELB}' < proxy.conf.json.template > proxy.conf.json
              envsubst '${WEB_PORT}' < package.json.template > package.json
              nohup npm start &
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "web" {
  launch_configuration = "${aws_launch_configuration.web.id}"

  vpc_zone_identifier = ["${module.vpc.public_subnets}"]

  load_balancers    = ["${module.elb_web.this_elb_name}"]
  health_check_type = "ELB"

  min_size = "${var.web_autoscale_min_size}"
  max_size = "${var.web_autoscale_max_size}"

  tags {
    key = "Group" 
    value = "${var.name}"
    propagate_at_launch = true
  }

}

variable "web_port" {
  description = "The port on which the web servers listen for connections"
  default = 80
}

variable "web_instance_type" {
  description = "The EC2 instance type for the web servers"
  default = "t2.micro"
}

variable "web_autoscale_min_size" {
  description = "The fewest amount of EC2 instances to start"
  default = 2
}

variable "web_autoscale_max_size" {
  description = "The largest amount of EC2 instances to start"
  default = 3
}

