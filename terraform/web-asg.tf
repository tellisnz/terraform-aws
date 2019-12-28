resource "aws_security_group" "web" {
  name = format("%s-web-sg", var.name)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = var.web_port
    to_port   = var.web_port
    protocol  = "tcp"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
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

  tags = {
    Group = var.name
    Name  = "web-sg"
  }
}

resource "aws_launch_configuration" "web" {
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.web_instance_type
  security_groups = [aws_security_group.web.id]

  #TODO REMOVE
  key_name    = var.web_key_pair_name
  name_prefix = "${var.name}-web-vm-"

  user_data = <<-EOF
              #!/bin/bash
              # install git/nginx
              yum install -y git gettext nginx
              echo "NETWORKING=yes" >/etc/sysconfig/network

              # install node
              curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
              . /.nvm/nvm.sh
              nvm install 6.11.5

              # setup sample app client
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/client
              npm install -g @angular/cli@1.1.0
              npm install
              export HOME=/root
              ng build
              rm /usr/share/nginx/html/*
              cp dist/* /usr/share/nginx/html/
              chown -R nginx:nginx /usr/share/nginx/html

              # configure and start nginx
              export APP_ELB="${module.elb_app.this_elb_dns_name}" APP_PORT="${var.app_port}" WEB_PORT="${var.web_port}"
              envsubst '$${APP_PORT} $${APP_ELB} $${WEB_PORT}' < nginx.conf.template > /etc/nginx/nginx.conf
              service nginx start
EOF


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "web" {
  launch_configuration = aws_launch_configuration.web.id

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_zone_identifier = module.vpc.public_subnets

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  load_balancers = [module.elb_web.this_elb_name]
  health_check_type = "EC2"

  min_size = var.web_autoscale_min_size
  max_size = var.web_autoscale_max_size

  tags = [
  {
    key = "Group"
    value = var.name
    Name = "web-asg-${var.name}"
    propagate_at_launch = true
  }
]
}
