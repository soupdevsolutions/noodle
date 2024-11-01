# INITIATE PAYMENT LAMBDA ROLE/POLICIES
resource "aws_iam_role" "initiate_payment" {
  assume_role_policy = data.aws_iam_policy_document.initiate_payment_assume_policy.json
}

data "aws_iam_policy_document" "initiate_payment_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "initiate_payment_policy_document" {
  statement {
    actions = [
      "dynamodb:PutItem",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*"
    ]
  }
}

resource "aws_iam_policy" "initiate_payment_policy" {
  name   = "initiate_payment_policy"
  policy = data.aws_iam_policy_document.initiate_payment_policy_document.json
}

resource "aws_iam_role_policy_attachment" "initiate_payment_policy_attachment" {
  role       = aws_iam_role.initiate_payment.name
  policy_arn = aws_iam_policy.initiate_payment_policy.arn
}

# FINISH PAYMENT LAMBDA ROLE/POLICIES
resource "aws_iam_role" "finish_payment" {
  assume_role_policy = data.aws_iam_policy_document.finish_payment_assume_policy.json
}

data "aws_iam_policy_document" "finish_payment_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "finish_payment_policy_document" {
  statement {
    actions = [
      "dynamodb:UpdateItem",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*"
    ]
  }
}

resource "aws_iam_policy" "finish_payment_policy" {
  name   = "finish_payment_policy"
  policy = data.aws_iam_policy_document.finish_payment_policy_document.json
}

resource "aws_iam_role_policy_attachment" "finish_payment_policy_attachment" {
  role       = aws_iam_role.finish_payment.name
  policy_arn = aws_iam_policy.finish_payment_policy.arn
}


# GET PAYMENTS LAMBDA ROLE/POLICIES
resource "aws_iam_role" "get_payments" {
  assume_role_policy = data.aws_iam_policy_document.get_payments_assume_policy.json
}

data "aws_iam_policy_document" "get_payments_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_payments_policy_document" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
    ]
    resources = [
      aws_dynamodb_table.payments.arn,
      "${aws_dynamodb_table.payments.arn}/index/*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*"
    ]
  }
}

resource "aws_iam_policy" "get_payments_policy" {
  name   = "get_payments_policy"
  policy = data.aws_iam_policy_document.get_payments_policy_document.json
}

resource "aws_iam_role_policy_attachment" "get_payments_policy_attachment" {
  role       = aws_iam_role.get_payments.name
  policy_arn = aws_iam_policy.get_payments_policy.arn
}
