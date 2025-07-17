terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

//IAM Perms for Lambda FUnction

# A Lambda function needs a "role" to get permission to run
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-exec-role"

  # The 'assume_role_policy' defines WHO can use this role
  # Here, we are trusting the AWS Lambda service itself
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# This policy gives the role permission to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


//AWS Lambda Function to be invoked
# This data source creates a zip file from the inline code
# This is what will be uploaded to AWS Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/hello.zip"
  
  # This is a single source file within the zip archive.
  source {
    content  = "exports.handler = async (event) => { console.log('Hello from Step Functions!', event); return { statusCode: 200, body: 'Success!' }; };"
    filename = "index.js"
  }
}

# This resource creates the actual Lambda function in AWS.
resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.project_name}-hello-world"
  role             = aws_iam_role.lambda_exec_role.arn
  
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  handler          = "index.handler" # The file is index.js, the function is 'handler'
  runtime          = "nodejs18.x"
}

//Step function IAM Role & Policy

# The Step Function also needs a role to get permissions
resource "aws_iam_role" "sfn_exec_role" {
  name = "${var.project_name}-sfn-exec-role"

  # The trust policy here allows the Step Functions service to assume this role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

# Trust policy defines WHAT the Step Function can do
# Granted permission to invoke the specific Lambda function
resource "aws_iam_policy" "sfn_policy" {
  name   = "${var.project_name}-sfn-policy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action   = "lambda:InvokeFunction" //Allowing the SFn to invoke LFn
      Effect   = "Allow"
      Resource = aws_lambda_function.hello_world.arn
    }]
  })
}

# Attach trust policy to the Step Function role
resource "aws_iam_role_policy_attachment" "sfn_policy_attach" {
  role       = aws_iam_role.sfn_exec_role.name
  policy_arn = aws_iam_policy.sfn_policy.arn
}


//Step function State Machine Definition

resource "aws_sfn_state_machine" "main" {
  name     = "${var.project_name}-state-machine"
  role_arn = aws_iam_role.sfn_exec_role.arn

  # This is the core of the technique
  # templatefile() reads the .tpl file and substitutes the variables
  definition = templatefile("${path.module}/sfn_workflow.json.tpl", {
    # The key here must match the placeholder name in the template file
    lambda_function_arn = aws_lambda_function.hello_world.arn
  })
}
