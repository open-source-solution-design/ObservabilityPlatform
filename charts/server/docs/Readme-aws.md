# Overview

# Prep

## Prep For AWS and EKS
* EKS Node Role  : kubernetes-node 
* POD Role       : bucket-accessor
* POD AssumeRole : kube2iam-default

Step1 kubernetes-node : create roles for your node to assume or have an IAM policy attached
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```

Step2 CloudWatchAgentServerRole: Create IAM Role for Log Agent Pod
CloudWatchAgentServerPolicy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws-cn:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ]
}
```
Trust Relationships
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com.cn"
                ]
            }
        }
    ]
}
```

Step3 kube2iam-default: Configure Assume Roles & Set trust policy 
Kube2iam-default-Policy
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::123456789012:role/CloudWatchAgentServerRole"
    }
  ]
}
```
Trust Relationships

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789012:role/kubernetes-node"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```
