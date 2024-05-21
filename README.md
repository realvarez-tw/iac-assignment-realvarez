# Infra as Code - Assignment for IaC Course

## Overview
This repository contain the code to deploy the infraestructure with terraform in the image below, this consist in two aws lambdas connected to an API Gateway v2.
The first lambda its a user register function, its conected to the api gateway recieving a GET request to the route `"/register"` with info of the user in the query parameters, this must include the field `user_name` that will be used as a key to the dynamoDB table that will store the data.
Then, the second lambda will be an user verify function conected to the same api gateway in the route `"/"` with a GET Method. This function receive the `user_name` as query parameter and search in the dynamo table, resurning access to a website contained in a S3 Bucket, this could be the welcome page or an error page, depending of if the user exist in the table or not.

![Assignment details and diagram](./images/assignment.png "")

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_user_registry"></a> [lambda\_user\_registry](#module\_lambda\_user\_registry) | terraform-aws-modules/lambda/aws | 7.4.0 |
| <a name="module_lambda_user_verify"></a> [lambda\_user\_verify](#module\_lambda\_user\_verify) | terraform-aws-modules/lambda/aws | 7.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.api_gw_lambda](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_deployment.api_gw2_lambda_deployments](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/apigatewayv2_deployment) | resource |
| [aws_apigatewayv2_integration.api_gw2_integrations](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.api_gw2_routes](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.apigw2_stage](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_log_group.api_gw_log_group](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_dynamodb_table.users_table](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/dynamodb_table) | resource |
| [aws_lambda_permission.apigw2_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.website_assignment_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.acl_website_assignment_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.bucket_ownership_website_assignment_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.encription_website_assignment_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_object.html_files_website](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoint_register"></a> [endpoint\_register](#input\_endpoint\_register) | value | `string` | `"register"` | no |
| <a name="input_endpoint_verify"></a> [endpoint\_verify](#input\_endpoint\_verify) | value | `string` | `""` | no |
| <a name="input_html_files"></a> [html\_files](#input\_html\_files) | n/a | `list(string)` | `["index.html","error.html"]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | prefix used as name of infra | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | aws region where is deploying the infrastructure | `string` | n/a | yes |

## Outputs

No outputs.

----------------------------------

## Using the code
###  Terraform prerequisites

This code repository contain three folders important folders used in the deploy