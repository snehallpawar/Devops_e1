terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "Snehal.Pawar"
    region = "ap-south-1"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.10.0/24"  # Change if needed
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

# Routing Table
resource "aws_route_table" "private_rt" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-security-group"
  }
}

# First Lambda Function (existing)
resource "aws_lambda_function" "lambda_function_v1" {
  function_name = "devops-exam-lambda"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_function.zip"
  timeout       = 10

  tags = {
    Name = "devops-lambda-v1"
  }
}

# Second Lambda Function (new version)
resource "aws_lambda_function" "lambda_function_v2" {
  function_name = "devops-exam-lambda-v2"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda_function.zip"
  timeout       = 10

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "devops-lambda-v2"
  }
}

# IAM Policy for Jenkins Lambda access
resource "aws_iam_policy" "jenkins_lambda_policy" {
  name        = "jenkins-lambda-policy"
  description = "Allow Jenkins to manage Lambda functions and tag them"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "lambda:CreateFunction",
          "lambda:TagResource",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:DeleteFunction"
        ]
        Resource = "arn:aws:lambda:ap-south-1:168009530589:function:*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "iam:CreatePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the Jenkins role
resource "aws_iam_role_policy_attachment" "jenkins_lambda_policy_attachment" {
  role       = "jenkins-role"  # The name of your Jenkins role
  policy_arn = aws_iam_policy.jenkins_lambda_policy.arn
}

# Output the subnet ID for later use
output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}
