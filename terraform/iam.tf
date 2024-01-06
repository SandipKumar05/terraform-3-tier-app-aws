resource "aws_iam_role" "cloud-watch-agent-role" {
  name = "cloud-watch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "policy-attachment" {
  name       = "policy-attachment"
  roles      = [aws_iam_role.cloud-watch-agent-role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm-policy-attachment" {
  role       = aws_iam_role.cloud-watch-agent-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "cloud-watch-agent-put-logs-retention" {
  name = "cloud-watch-agent-put-logs-retention"
  role = aws_iam_role.cloud-watch-agent-role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "logs:PutRetentionPolicy",
        "Resource" : "*"
      }
    ]
  })
}