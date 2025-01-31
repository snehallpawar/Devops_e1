pipeline {
    agent any
    environment {
        AWS_REGION = "ap-south-1"
        BUCKET_NAME = "467.devops.candidate.exam"
        STATE_KEY = "Snehal.Pawar"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/<YourGitHubUsername>/devops-exam.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                terraform init \
                  -backend-config="bucket=$BUCKET_NAME" \
                  -backend-config="region=$AWS_REGION" \
                  -backend-config="key=$STATE_KEY"
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Deploy Lambda') {
            steps {
                sh 'aws lambda update-function-code --function-name devops-exam-lambda --zip-file fileb://lambda_function.zip'
            }
        }

        stage('Invoke Lambda') {
            steps {
                sh 'aws lambda invoke --function-name devops-exam-lambda --log-type Tail response.json'
                sh 'cat response.json | jq -r \'.LogResult\' | base64 --decode'
            }
        }
    }
}

