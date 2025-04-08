output "config" {
  description = "Backend configuration values for use in remote_state blocks or Terragrunt"

  value = {
    bucket         = aws_s3_bucket.this.bucket
    region         = data.aws_region.current.name
    role_arn       = aws_iam_role.this.arn
    dynamodb_table = try(aws_dynamodb_table.this[0].name, null)
  }
}