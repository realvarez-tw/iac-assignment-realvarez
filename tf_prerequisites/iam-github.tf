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
          "s3:GetObject",
          "s3:PutObject",

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

          "ec2:*Instance*",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateVpc",
          "ec2:CreateTags",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:CreateSubnet",
          "ec2:CreateSecurityGroup",
          "ec2:AttachInternetGateway",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInternetGateways",
          "ec2:AssociateRouteTable",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:AllocateAddress",
          "ec2:CreateRoute",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:DescribeAddresses",
          "ec2:CreateNatGateway",
        
          "dynamodb:*",

          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",

          "rds:CreateDBParameterGroup",
          "rds:AddTagsToResource",
          "rds:ModifyDBParameterGroup",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBParameters",
          "rds:ListTagsForResource",
          "rds:CreateDBSubnetGroup",
          "rds:DescribeDBSubnetGroups",
          "rds:CreateDBInstance",
          "rds:GetDBInstance",
          "rds:DescribeDBInstances",
          
          "ecs:CreateCluster",
          "ecs:TagResource",
          "ecs:DescribeClusters",
          "ecs:PutClusterCapacityProviders",
          
          "ecr:CreateRepository",
          "ecr:TagResource",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          
          "logs:CreateLogGroup",
          "logs:TagResource",
          "logs:PutRetentionPolicy",
          "logs:DescribeLogGroups",
          "logs:ListTagsLogGroup",
          
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancer",
          "elasticloadbalancing:GetLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTags",

          
          
          

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