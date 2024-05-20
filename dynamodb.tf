resource "aws_dynamodb_table" "users_table" {
  name         = format("%s-table-users", var.prefix)
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_name"

  attribute {
    name = "user_name"
    type = "S"
  }
}