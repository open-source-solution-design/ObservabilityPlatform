# Overview

# Prep

## Prep For AWS and EKS

for example:

* EKS Node Role  : AmazonEKSNodeRole 
* POD Role       : CloudWatchAgentServerRole

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
CloudWatchFullAccess
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:*",
                "logs:*",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws-cn:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "events.amazonaws.com"
                }
            }
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
                "Service": "ec2.amazonaws.com.cn"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws-cn:iam::155742804536:role/AmazonEKSNodeRole"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```


curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
