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
  filename      = "C:/lambda_function.zip"
  timeout       = 10

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "devops-lambda"
  }
}



# Define your Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = "invoke-api-lambda"
  
  s3_bucket = "your-s3-bucket"
  s3_key    = "lambda_function.zip"  # This is the path to your Lambda zip file
  
  runtime = "python3.8"
  handler = "lambda_function.lambda_handler"
  
  environment {
    variables = {
      SUBNET_ID = "${aws_subnet.private_subnet.id}"  # The private subnet ID from your Terraform code
    }
  }
  
  # VPC configuration
  vpc_config {
    subnet_ids = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

# Create security group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Lambda security group"
  vpc_id      = aws_vpc.main.id
}

# Example of how to reference the private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false
}

# Make sure to output the subnet_id for later use
output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}


