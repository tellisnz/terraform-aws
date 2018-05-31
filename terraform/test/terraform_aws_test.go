package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAws(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()

	name := fmt.Sprintf("terraform-aws-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name": name,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	instanceURL := "http://" + terraform.Output(t, terraformOptions, "elb_dns_name")

	maxRetries := 30
	timeBetweenRetries := 10 * time.Second

	indexBody := `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Angular4Client</title>
  <base href="/">

  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="stylesheet" href="https:maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
</head>
<body>
  <app-root></app-root>
<script type="text/javascript" src="inline.bundle.js"></script><script type="text/javascript" src="polyfills.bundle.js"></script><script type="text/javascript" src="styles.bundle.js"></script><script type="text/javascript" src="vendor.bundle.js"></script><script type="text/javascript" src="main.bundle.js"></script></body>
</html>`

	http_helper.HttpGetWithRetry(t, instanceURL, 200, indexBody, maxRetries, timeBetweenRetries)
}
