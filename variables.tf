variable "namespace" {
  description = "Project namespace to prefix S3/DynamoDB resources for uniqueness (e.g. 'velocivtech' or 'team-rocket')"
  type        = string

  validation {
    condition     = length(var.namespace) > 2 && length(var.namespace) < 64
    error_message = "Namespace must be between 3 and 63 characters."
  }
}

variable "principal_arns" {
  description = "Optional list of AWS principal ARNs allowed to assume IAM roles related to state access. Useful for additional trust policies."
  type        = list(string)
  default     = []
}

variable "force_destroy_state" {
  description = "If true, the S3 bucket can be destroyed even if it contains Terraform state objects. Use with caution."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type = map(string)
  default = {
    Owner       = "infra@velocivtech.com"
    Project     = "terraform-backend"
    CostCenter  = "infra"
    Environment = "infrastructure"
  }
}

variable "enable_locking" {
  description = "Enable DynamoDB state locking for Terraform."
  type        = bool
  default     = true
}

variable "principal_org_id" {
  description = "Optional AWS Organization ID to restrict who can assume the IAM role"
  type        = string
  default     = null
}
