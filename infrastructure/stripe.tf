resource "stripe_webhook_endpoint" "payments_webhook" {
  url = format("%s%s", aws_apigatewayv2_stage.api_stage.invoke_url, "api/payment/finish")

  enabled_events = [
    "charge.succeeded",
    "charge.failed"
  ]
}
