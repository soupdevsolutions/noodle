resource "aws_s3_bucket" "noodle_frontend" {
  bucket = "${local.app_name}-payments-frontend"
}

resource "aws_s3_bucket_website_configuration" "noodle_frontend" {
  bucket = aws_s3_bucket.noodle_frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "noodle_frontend_pab" {
  bucket = aws_s3_bucket.noodle_frontend.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "noodle_frontend_bp" {
  bucket = aws_s3_bucket.noodle_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.noodle_frontend.arn,
          "${aws_s3_bucket.noodle_frontend.arn}/*",
        ]
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.noodle_frontend_pab]
}
