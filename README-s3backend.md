# terraform-aws-s3backend-alienvera

A reusable Terraform module to provision a secure, versioned **S3 backend** for storing Terraform state files.  
Includes optional **DynamoDB locking** and supports tagging, encryption, and Terragrunt compatibility.

---

## 🚀 Features

- 🔐 S3 Bucket for remote state with versioning
- 🧱 Optional DynamoDB Table for state locking
- 🔑 Optional server-side encryption (SSE)
- 🏷️ Custom tags for cost tracking and governance
- 🤝 Works great with [Terragrunt](https://terragrunt.gruntwork.io/)

---

## 📦 Usage

```hcl
module "backend" {
  source  = "github.com/alienvera/terraform-aws-s3backend-alienvera"
  bucket_name           = "my-terraform-state-bucket"
  enable_locking        = true
  enable_encryption     = true
  region                = "us-east-1"
  tags = {
    Owner       = "you@velocivtech.com"
    Project     = "terraform-backend"
    CostCenter  = "infra"
  }
}
```

---

## 🧰 Inputs

| Name                | Type    | Description                               | Default     |
|---------------------|---------|-------------------------------------------|-------------|
| `bucket_name`       | string  | Name of the S3 bucket                     | **required**|
| `region`            | string  | AWS region to deploy resources            | `"us-east-1"` |
| `enable_locking`    | bool    | Whether to create a DynamoDB lock table   | `true`      |
| `enable_encryption` | bool    | Whether to enable SSE encryption on bucket| `false`     |
| `tags`              | map     | Resource tags                             | `{}`        |

---

## 📤 Outputs

| Name               | Description                         |
|--------------------|-------------------------------------|
| `bucket`           | The S3 bucket name                  |
| `lock_table`       | DynamoDB table name (if created)    |
| `region`           | The AWS region used                 |

---

## 🛡️ Security Notes

- Bucket is versioned and protected with `prevent_destroy`
- DynamoDB table uses `PAY_PER_REQUEST` billing
- Optional SSE support (KMS can be added in future)

---

## 🧪 Example with Terragrunt

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state-bucket"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-lock-table"
    encrypt        = true
  }
}
```

---

## 👨‍💻 Author

**[Alien Vera](https://github.com/alienvera)**  
Brought to you by [VelocivTech](https://velocivtech.com)

---

## 📝 License

MIT
