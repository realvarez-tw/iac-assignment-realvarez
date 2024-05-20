terraform {
  backend "s3" {
    bucket = "iac-assignment-realvarez-tfstate"
    key    = "tf_state"
    region = "sa-east-1"

    dynamodb_table = "iac-assignment-realvarez-tfstate-locks"
    encrypt        = true
  }
}
