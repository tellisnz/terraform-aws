resource "aws_security_group" "app" {
  name = "${format("%s-app-sg", var.name)}"

  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks}", "${module.vpc.private_subnets_cidr_blocks}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks}"]
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

resource "aws_launch_configuration" "app" {
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "${var.app_instance_type}"
  security_groups = ["${aws_security_group.app.id}"]
  #TODO REMOVE
  key_name = "web-key"
  name_prefix = "${var.name}-app-vm-"

  user_data = <<-EOF
              #!/bin/bash
              yum install -y busybox
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.app_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "app" {
  launch_configuration = "${aws_launch_configuration.app.id}"

  vpc_zone_identifier = ["${module.vpc.private_subnets}"]

  load_balancers    = ["${module.elb_app.this_elb_name}"]
  health_check_type = "ELB"

  min_size = "${var.app_autoscale_min_size}"
  max_size = "${var.app_autoscale_max_size}"

  tags {
    key = "Group"
    value = "${var.name}"
    propagate_at_launch = true
  }

}

variable "app_port" {
  description = "The port on which the application listens for connections"
  default = 8080
}

variable "app_instance_type" {
  description = "The EC2 instance type for the application servers"
  default = "t2.micro"
}

variable "app_autoscale_min_size" {
  description = "The fewest amount of EC2 instances to start"
  default = 2
}

variable "app_autoscale_max_size" {
  description = "The largest amount of EC2 instances to start"
  default = 3
}
