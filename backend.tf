terraform {

  backend "s3" {
    bucket         = "destination-bucket"
    dynamodb_table = "dynamodb-lock"
    key            = "statefile.tfstate/jsonanalysis"
    region         = "region-of-bucket"
    encrypt        = true

  }
}
