resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal"
  }
}

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_role_policy" "vault-kms-unseal" {
  name   = "vault-kms-unseal-role"
  role   = aws_iam_role.ec2-node-role.name
  policy = data.aws_iam_policy_document.vault-kms-unseal.json

  depends_on = [aws_kms_key.vault]
}