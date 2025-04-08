
# terraform-aws-s3backend-alienvera

A reusable module to provision a secure, flexible Terraform backend in AWS using S3 and DynamoDB, with IAM role-based access for CI/CD, cross-account usage, or organization-wide access.

---

## 🚀 Features

- 💾 S3 bucket for Terraform state (with optional force destroy)
- 🔐 Optional DynamoDB table for state locking
- 🎭 IAM role for secure access 
- ✅ Support for both:
  - `principal_arns`: list of IAM ARNs
  - `principal_org_id`: restricts to principals in an AWS Organization
- 🏷️ Taggable resources
- 🧱 Built with AWS provider v5+

---

## 📦 Example Usage

```hcl
module "backend" {
  source  = "alienvera/s3backend/aws"
  version = "2.0.0"

  namespace         = "velocivtech"

  # Option 1: allow specific IAM roles
  # principal_arns = ["arn:aws:iam::123456789012:role/ci-role"]

  # Option 2: allow all principals in an AWS Organization
  principal_org_id  = "o-dkasldjk"

  force_destroy_state = false
  enable_locking      = true

  tags = {
    Owner       = "infra@velocivtech.com"
    Project     = "terraform-backend"
    CostCenter  = "infra"
    Environment = "infrastructure"
  }
}
```

---

## 🔐 IAM Trust Logic

The role trust policy is dynamically built:
- If `principal_arns` is provided, uses that list
- If `principal_org_id` is set (and `principal_arns` is empty), allows `"*"` but restricts via condition:
  ```json
  "Condition": {
    "StringEquals": {
      "aws:PrincipalOrgID": "o-xxxxxxx"
    }
  }
  ```

---

## 📥 Inputs

| Name                  | Description                                                                 | Type           | Default         | Required |
|-----------------------|-----------------------------------------------------------------------------|----------------|------------------|----------|
| `namespace`           | The project namespace for naming all resources                             | `string`       | n/a              | ✅ Yes   |
| `principal_arns`      | List of IAM ARNs that can assume the Terraform role                         | `list(string)` | `[]`             | ❌ No    |
| `principal_org_id`    | AWS Organization ID to trust any principal from your org                    | `string`       | `null`           | ❌ No    |
| `force_destroy_state` | Force destroy the S3 bucket (useful for dev/test environments)              | `bool`         | `true`           | ❌ No    |
| `enable_locking`      | Enable DynamoDB table for state locking                                     | `bool`         | `true`           | ❌ No    |
| `tags`                | Tags to apply to all resources                                              | `map(string)`  | `{}`             | ❌ No    |

---

## 📤 Outputs

```hcl
output "config" {
  value = {
    bucket         = aws_s3_bucket.this.bucket
    region         = data.aws_region.current.name
    role_arn       = aws_iam_role.this.arn
    dynamodb_table = try(aws_dynamodb_table.this[0].name, null)
  }
}
```

Great for using in Terragrunt’s `remote_state` block or other modules.

---

## 🧪 Tested With

- Terraform v1.3+
- AWS Provider v5.x

---

## 🛡️ License

MIT © AlienVera
