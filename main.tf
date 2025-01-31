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

