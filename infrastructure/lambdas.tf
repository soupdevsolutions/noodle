# INITIATE PAYMENT
resource "aws_lambda_function" "initiate_payment_lambda" {
  function_name = "InitiatePayment"

  filename         = "data/lambdas/initiate_payment.zip"
  source_code_hash = filebase64sha256("data/lambdas/initiate_payment.zip")

  handler = "handler"
  runtime = "provided.al2023"

  role = aws_iam_role.initiate_payment.arn

  environment {
    variables = {
      STRIPE_SECRET_KEY         = var.STRIPE_API_KEY
      PAYMENTS_TABLE_NAME       = aws_dynamodb_table.payments.name
      DOMAIN                    = "http://${local.domain_name}"
      PAYMENTS_CREATED_AT_INDEX = "CreatedAtIndex"
    }
  }
}

# FINISH PAYMENT
resource "aws_lambda_function" "finish_payment_lambda" {
  function_name = "FinishPayment"

  source_code_hash = filebase64sha256("data/lambdas/finish_payment.zip")
  filename         = "data/lambdas/finish_payment.zip"

  handler = "handler"
  runtime = "provided.al2023"

  role = aws_iam_role.finish_payment.arn

  environment {
    variables = {
      PAYMENTS_TABLE_NAME       = aws_dynamodb_table.payments.name
      STRIPE_WEBHOOK_SECRET     = stripe_webhook_endpoint.payments_webhook.secret
      DOMAIN                    = "http://${local.domain_name}"
      PAYMENTS_CREATED_AT_INDEX = "CreatedAtIndex"
    }
  }
}


# GET PAYMENTS
resource "aws_lambda_function" "get_payments_lambda" {
  function_name = "GetPayments"

  source_code_hash = filebase64sha256("data/lambdas/get_payments.zip")
  filename         = "data/lambdas/get_payments.zip"

  handler = "handler"
  runtime = "provided.al2023"

  role = aws_iam_role.get_payments.arn

  environment {
    variables = {
      PAYMENTS_TABLE_NAME       = aws_dynamodb_table.payments.name
      PAYMENTS_CREATED_AT_INDEX = "CreatedAtIndex"
    }
  }
}
