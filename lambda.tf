module "lambda_user_registry" {
  source = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"

  function_name = format("%s-users_register", var.prefix)
  description   = "Lambda function for user registry"
  handler       = "register_user.lambda_handler"
  runtime       = "python3.10"

  source_path = "./src/register_user.py"
  publish     = true

  environment_variables = {
    DB_TABLE_NAME = aws_dynamodb_table.users_table.name
    Serverless    = "Terraform"
  }

  cloudwatch_logs_log_group_class = "STANDARD"

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }

  invoke_mode              = "RESPONSE_STREAM"
  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem"
      ],
      resources = [aws_dynamodb_table.users_table.arn]
    }
  }

  tags = {
    Name = "lambda_user_registry"
  }
}


module "lambda_user_verify" {
  source = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"
  
  function_name = format("%s-users_verify", var.prefix)
  description   = "Lambda function for user verify"
  handler       = "verify_user.lambda_handler"
  runtime       = "python3.10"

  source_path = "./src/verify_user.py"
  publish     = true

  environment_variables = {
    DB_TABLE_NAME = aws_dynamodb_table.users_table.name
    WEBSITE_S3    = aws_s3_bucket.website_assignment_bucket.id
  }

  cloudwatch_logs_log_group_class = "STANDARD"

  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }

  invoke_mode              = "RESPONSE_STREAM"
  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect = "Allow",
      actions = [
        "dynamodb:GetItem"
      ],
      resources = [aws_dynamodb_table.users_table.arn]
    },
    s3_read = {
      effect = "Allow",
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      resources = [
        format("%s/*", aws_s3_bucket.website_assignment_bucket.arn)
      ]
    }
  }
  tags = {
    Name = "lambda_user_registry"
  }
}

