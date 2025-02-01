pipeline {
    agent any
    stages {
        stage("TF Init") {
            steps {
                script {
                    echo "Executing Terraform Init"
                    sh 'terraform init'  // Initialize the Terraform working directory
                }
            }
        }
        stage("TF Validate") {
            steps {
                script {
                    echo "Validating Terraform Code"
                    sh 'terraform validate'  // Validate the Terraform configuration
                }
            }
        }
        stage("TF Plan") {
            steps {
                script {
                    echo "Executing Terraform Plan"
                    sh 'terraform plan'  // Generate an execution plan for Terraform
                }
            }
        }
        stage("TF Apply") {
            steps {
                script {
                    echo "Executing Terraform Apply"
                    sh 'terraform apply -auto-approve'  // Apply the changes automatically without manual approval
                }
            }
        }
        stage("Invoke Lambda") {
            steps {
                script {
                    echo "Invoking your AWS Lambda"
                    // Example to invoke the Lambda function using AWS CLI
                    // Replace with actual function name and payload if required
                    sh 'aws lambda invoke --function-name devops-exam-lambda-v2 output.txt'  // Invoke the Lambda function
                }
            }
        }
    }
}
