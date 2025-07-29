output "secret_arn" {
  value = aws_secretsmanager_secret.app_secret.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.secure_lambda.function_name
}
