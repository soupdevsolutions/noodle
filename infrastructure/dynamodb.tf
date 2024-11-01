resource "aws_dynamodb_table" "payments" {
  name         = "Payments"
  hash_key     = "id"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "created_at_index"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "N"
  }

  global_secondary_index {
    name            = "CreatedAtIndex"
    hash_key        = "created_at_index"
    range_key       = "created_at"
    write_capacity  = 5
    read_capacity   = 5
    projection_type = "ALL"
  }
}
