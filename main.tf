terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "Santosh.Dongare"
    region = "ap-south-1"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"  # Change if needed
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

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = "devops-exam-lambda"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"
  timeout       = 10

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "devops-lambda"
  }
}

