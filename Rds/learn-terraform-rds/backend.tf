###################### state File ################

terraform {
  backend "s3" {
    bucket               = "myrdsbucket"
    region               = "us-east-1"
    key                  = "Rds"
    #dynamodb_table       = ""
    encrypt              = true
  }
}
