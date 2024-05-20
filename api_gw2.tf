locals {
  lambda_quantity = 2
  lambda_functions = [
    module.lambda_user_registry,
    module.lambda_user_verify
  ]
  api_gw_route_keys = [
    format("GET /%s", var.endpoint_register), 
    format("GET /%s", var.endpoint_verify)
  ]
}

resource "aws_apigatewayv2_api" "api_gw_lambda" {
  name          = format("%s-api-gw-lambda", var.prefix)
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "api_gw_log_group" {
  name = format("%s-api-gw-log", var.prefix)
}

resource "aws_apigatewayv2_stage" "apigw2_stage" {
  api_id      = aws_apigatewayv2_api.api_gw_lambda.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_log_group.arn
    format = jsonencode({
      "requestId" : "$context.requestId",
      "extendedRequestId" : "$context.extendedRequestId",
      "ip" : "$context.identity.sourceIp",
      "caller" : "$context.identity.caller",
      "user" : "$context.identity.user",
      "requestTime" : "$context.requestTime",
      "httpMethod" : "$context.httpMethod",
      "resourcePath" : "$context.resourcePath",
      "status" : "$context.status",
      "protocol" : "$context.protocol",
      "responseLength" : "$context.responseLength",
      "integrationErrorMessage" : "$context.integrationErrorMessage",
      "errorMessage" : "$context.error.message",
      "errorResponseType" : "$context.error.responseType"
    })
  }
}

resource "aws_apigatewayv2_integration" "api_gw2_integrations" {
  count              = local.lambda_quantity
  api_id             = aws_apigatewayv2_api.api_gw_lambda.id
  integration_type   = "AWS_PROXY"
  integration_uri    = local.lambda_functions[count.index].lambda_function_invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gw2_routes" {
  count     = local.lambda_quantity
  api_id    = aws_apigatewayv2_api.api_gw_lambda.id
  route_key = local.api_gw_route_keys[count.index]
  target    = "integrations/${aws_apigatewayv2_integration.api_gw2_integrations[count.index].id}"
}

resource "aws_apigatewayv2_deployment" "api_gw2_lambda_deployments" {
  count       = local.lambda_quantity
  api_id      = aws_apigatewayv2_api.api_gw_lambda.id
  description = "Deployment of apigateway v2"
  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.api_gw2_integrations[count.index]),
      jsonencode(aws_apigatewayv2_route.api_gw2_routes[count.index]),
      ]))
    )
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apigw2_lambda_permission" {
  count         = local.lambda_quantity
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_functions[count.index].lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gw_lambda.execution_arn}/*/*"
}
