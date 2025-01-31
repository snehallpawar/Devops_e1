pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        TF_VAR_subnet_id = "${output.private_subnet_id}"
    }

    stages {
        stage('Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply') {
            steps {
                script {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Invoke Lambda') {
            steps {
                script {
                    // Invoke Lambda function using AWS CLI
                    sh """
                    aws lambda invoke \
                        --function-name invoke-api-lambda \
                        --payload '{}' \
                        --log-type Tail \
                        output.txt
                    """

                    // Decode the base64 log result from Lambda and display it
                    sh """
                    base64 -d output.txt > decoded_output.txt
                    cat decoded_output.txt
                    """
                }
            }
        }
    }
}

