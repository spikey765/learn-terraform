{
  "Comment": "A workflow that invokes a specific Lambda function",
  "StartAt": "InvokeLambda",
  "States": {
    "InvokeLambda": {
      "Type": "Task",
      "Resource": "${lambda_function_arn}",
      "End": true
    }
  }
}