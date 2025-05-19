pipeline {
    agent any

    environment {
        // Docker Hub credentials
        DOCKER_HUB_CREDS = credentials('DOCKERHUB_CREDENTIALS')
        // SSH key for EC2 instance
        EC2_KEY = credentials('EC2_PEM_KEY')
        // EC2 server IP
        REMOTE_HOST = credentials('SERVER_IP')
        // Docker image name
        IMAGE_NAME = 'khushboo053/jenkinsdemo'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "📥 Cloning the GitHub Repository..."
                checkout scm // Automatically uses the configured SCM (GitHub in this case)
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🔧 Building Docker Image..."
                    sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "🚀 Logging into Docker Hub..."
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDS}") {
                        sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "🚀 Deploying to EC2..."
                    sshagent(['EC2_PEM_KEY']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${REMOTE_HOST} << EOF
                        docker pull ${IMAGE_NAME}:${env.BUILD_NUMBER}
                        docker stop myapp || true
                        docker rm myapp || true
                        docker run -d --name myapp -p 80:80 ${IMAGE_NAME}:${env.BUILD_NUMBER}
                        EOF
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
    }
}
