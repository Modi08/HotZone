terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_lambda_function" "GetDetailsonUserHotZone" {
  filename      = "dummy.zip"
  function_name = "GetDetailsonUserHotZone"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "LoginUser" {
  filename      = "dummy.zip"
  function_name = "LoginUser"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 3
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "SignupUser" {
  filename      = "dummy.zip"
  function_name = "SignupUser"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 3
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "challengeUser" {
  filename      = "dummy.zip"
  function_name = "challengeUser"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "disconnectFromRoom" {
  filename      = "dummy.zip"
  function_name = "disconnectFromRoom"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 8
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "getActivitiesDetailsHotZone" {
  filename      = "dummy.zip"
  function_name = "getActivitiesDetailsHotZone"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "getDetailsOnUsers" {
  filename      = "dummy.zip"
  function_name = "getDetailsOnUsers"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "getRoomDetails" {
  filename      = "dummy.zip"
  function_name = "getRoomDetails"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "joinGame" {
  filename      = "dummy.zip"
  function_name = "joinGame"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 7
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "joinLocationChat" {
  filename      = "dummy.zip"
  function_name = "joinLocationChat"
  role          = "arn:aws:iam::566327990901:role/DynamoDbLambaExectionRole"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "playMove" {
  filename      = "dummy.zip"
  function_name = "playMove"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 10
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "quitActivity" {
  filename      = "dummy.zip"
  function_name = "quitActivity"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 3
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "saveProfilePic" {
  filename      = "dummy.zip"
  function_name = "saveProfilePic"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 5
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "sendMsgToLocationChat" {
  filename      = "dummy.zip"
  function_name = "sendMsgToLocationChat"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 60
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}


resource "aws_lambda_function" "updateLocation" {
  filename      = "dummy.zip"
  function_name = "updateLocation"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 3
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "updateProfile" {
  filename      = "dummy.zip"
  function_name = "updateProfile"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 3
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key, s3_object_version, source_code_hash]
  }
}

resource "aws_lambda_function" "validateUser" {
  filename      = "dummy.zip"
  function_name = "validateUser"
  role          = "arn:aws:iam::566327990901:role/LambdaDynamoDbAccess"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 128
  timeout       = 3
  tags = {
    project = "hotzone"
  }
  lifecycle {
    ignore_changes = [filename, s3_bucket, s3_key,.tf