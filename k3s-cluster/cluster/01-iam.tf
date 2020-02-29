resource "aws_iam_policy" "k3s-ecr-policy" {
  name        = "k3s-ecr-policy"
  path        = "/"
  description = "k3s-ecr-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:CreateCluster",
                "ec2:DescribeTags",
                "ecs:DeregisterContainerInstance",
                "ecs:DiscoverPollEndpoint",
                "ecs:Poll",
                "ecs:RegisterContainerInstance",
                "ecs:StartTelemetrySession",
                "ecs:UpdateContainerInstancesState",
                "ecs:Submit*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_instance_profile" "k3s-role" {
  name = "k3s-role"
  role = aws_iam_role.k3s-role.name

  depends_on = [aws_iam_role.k3s-role]
}

resource "aws_iam_role" "k3s-role" {
  name = "k3s-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

}

resource "aws_iam_policy_attachment" "attach-k3s-ecr-policy" {
  name       = "${aws_iam_policy.k3s-ecr-policy.name}"
  roles      = ["${aws_iam_role.k3s-role.name}"]
  policy_arn = "${aws_iam_policy.k3s-ecr-policy.arn}"
}