pipeline {
    agent any
    stages {
        stage('Checkout SCM') {
            steps {
                // Explicitly use 'main' branch to avoid any confusion
                git branch: 'main', url: 'https://github.com/snehallpawar/Devops_e1.git'
            }
        }
        stage('Checkout Code') {
            steps {
                // Ensure we are checking out the correct branch (main)
                git branch: 'main', url: 'https://github.com/snehallpawar/Devops_e1.git'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
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
