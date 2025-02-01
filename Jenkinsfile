pipeline {
    agent any
    environment {
        AWS_REGION = 'eu-west-1'  // Set your AWS region
        LAMBDA_FUNCTION_NAME = 'api-invoker-lambda'  // Change this to your actual Lambda function name
    }
    stages {
        stage("TF Init") {
    steps {
        script {
            echo "Executing Terraform Init with Reconfigure"
            sh 'terraform init -reconfigure'
        }
    }
}

        stage("TF Validate") {
            steps {
                script {
                    echo "Validating Terraform Code"
                    sh 'terraform validate'
                }
            }
        }
        stage("TF Plan") {
            steps {
                script {
                    echo "Executing Terraform Plan"
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        stage("TF Apply") {
            steps {
                script {
                    echo "Executing Terraform Apply"
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage("Invoke Lambda") {
            steps {
                script {
                    echo "Invoking AWS Lambda"
                    sh '''
                    echo "Calling AWS Lambda function..."
                    
                    # Ensure jq is installed
                    if ! command -v jq &> /dev/null
                    then
                        echo "jq could not be found, please install it"
                        exit 1
                    fi

                    # Invoke Lambda
                    aws lambda invoke \
                        --function-name $LAMBDA_FUNCTION_NAME \
                        --log-type Tail \
                        --region $AWS_REGION \
                        output.json
                    
                    # Extract and decode LogResult
                    if [ -s output.json ]; then
                        LOG_RESULT=$(jq -r '.LogResult' output.json | base64 --decode)
                        echo "Lambda Response: $LOG_RESULT"
                    else
                        echo "Error: output.json is empty or not found!"
                        exit 1
                    fi
                    '''
                }
            }
        }
    }
}
