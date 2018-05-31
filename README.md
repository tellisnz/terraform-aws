# Terraform and AWS

A template and configuration that reuses modules from the terraform registry to
create a three tier VPC and deploy a sample app to it, where:

The public presentation tier is an nginx host serving AngularJS static content
that passes API requests through to the private application tier.

The private application tier hosts a spring boot application that persists data
in the DB tier.

The db tier hosts an RDS PostgreSQL instance.

Sample app from (here)[http://javasampleapproach.com/spring-framework/spring-mvc/angular-4-spring-jpa-postgresql-example-angular-4-http-client-spring-boot-restapi-server].

# Usage

Take a copy of terraform.tfvars.template and substitute required values.

Apply as per normal, i.e. `terraform apply -var-file=terraform.tfvars`

# Testing

Install go and deps and check out code to $GOPATH/src

Run `go test -v -timeout 20m -run TestTerraformAws`
