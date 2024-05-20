locals {
  gihub_oidc_already_exists = true
}
resource "aws_iam_openid_connect_provider" "default" {
  count                       = local.gihub_oidc_already_exists ? 0 : 1
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "iam" {
  name = format("%s-github-deployment-policy", var.prefix)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:CreateBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:*",

          "iam:CreateRole",
          "iam:PassRole",
          "iam:TagRole",
          "iam:GetRole",
          "iam:CreatePolicy",
          "iam:TagPolicy",
          "iam:ListRolePolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:AttachRolePolicy",

          "dynamodb:*",

          "logs:CreateLogGroup",
          "logs:TagResource",
          "logs:PutRetentionPolicy",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          "logs:CreateLogDelivery",

          "apigateway:POST",
          "apigateway:GET",
          "apigateway:TagResource",
          "apigateway:DELETE",

          "lambda:CreateFunction",
          "lambda:TagResource",
          "lambda:GetFunction",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:AddPermission",
          "lambda:GetPolicy",
          "lambda:RemovePermission"

          # Likely to need more or different permissions for successful deployment
          # but you want to try to use least privilege principle where possible
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "role_policy_attachment" {
  name       = "Policy Attachement"
  policy_arn = aws_iam_policy.iam.arn
  roles      = [aws_iam_role.github_actions_role.name]
}

resource "aws_iam_role" "github_actions_role" {
  name = format("%s-github-actions-role", var.prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", data.aws_caller_identity.current.id)
        }
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : format("repo:%s:*", var.repo_name)
          },
          "ForAllValues:StringEquals" : {
            "token.actions.githubusercontent.com:iss" : "https://token.actions.githubusercontent.com",
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}