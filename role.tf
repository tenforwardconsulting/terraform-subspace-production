data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.delegated_access_account_id]
    }

    condition {
      test = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = [ true ]
    }
  }
}

resource aws_iam_role "delegated_access" {
  name = "DelegatedAccess"
  description = "Delegate access to third party (subspace)"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
