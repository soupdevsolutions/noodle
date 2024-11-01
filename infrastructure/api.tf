# GENERIC RESOURCES
resource "aws_apigatewayv2_api" "api" {
  name          = "${local.app_name}-api"
  description   = "API for ${local.app_name}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  domain_name = local.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.grabnoodle_eu.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  depends_on = [aws_acm_certificate_validation.grabnoodle_eu]
}

# INITIATE PAYMENT
resource "aws_apigatewayv2_integration" "initiate_payment_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Initiate Payment"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.initiate_payment_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "initiate_payment_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /api/payment/initiate"
  target    = "integrations/${aws_apigatewayv2_integration.initiate_payment_integration.id}"
}

resource "aws_lambda_permission" "initiate_payment_api_permission" {
  function_name = aws_lambda_function.initiate_payment_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# FINISH PAYMENT
resource "aws_apigatewayv2_integration" "finish_payment_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Finish Payment"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.finish_payment_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "finish_payment_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /api/payment/finish"
  target    = "integrations/${aws_apigatewayv2_integration.finish_payment_integration.id}"
}

resource "aws_lambda_permission" "finish_payment_api_permission" {
  function_name = aws_lambda_function.finish_payment_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}


# GET PAYMENTS
resource "aws_apigatewayv2_integration" "get_payments_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Get Payments"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.get_payments_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_payments_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /api/payments"
  target    = "integrations/${aws_apigatewayv2_integration.get_payments_integration.id}"
}

resource "aws_lambda_permission" "get_payments_api_permission" {
  function_name = aws_lambda_function.get_payments_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
