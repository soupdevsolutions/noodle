output "api_gateway_url" {
  value = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.noodle_frontend.bucket
}
