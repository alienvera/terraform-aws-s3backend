# IAM role + policy for Terraform state access

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  principal_arns = length(var.principal_arns) > 0 ? var.principal_arns : [data.aws_caller_identity.current.arn]
  use_org_id     = var.principal_org_id != null && length(var.principal_arns) == 0
}

resource "aws_iam_role" "this" {
  name = "${var.namespace}-tf-assume-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.use_org_id ? "*" : local.principal_arns
        }
        Action = "sts:AssumeRole"
        Condition = local.use_org_id ? {
          StringEquals = {
            "aws:PrincipalOrgID" = var.principal_org_id
          }
        } : null
      }
    ]
  })

  tags = var.tags
}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  dynamic "statement" {
    for_each = var.enable_locking ? [1] : []
    content {
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
      resources = [aws_dynamodb_table.this[0].arn] #test
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.namespace}-tf-policy"
  policy = data.aws_iam_policy_document.this.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
