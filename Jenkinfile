pipeline {
    agent any

    environment {
        SERVER_IP = credentials('SERVER_IP')
        DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
        DOCKERHUB_PASSWORD = credentials('DOCKERHUB_PASSWORD')
    }

    triggers {
        pollSCM('H/1 * * * *') // Polling every minute (H/1 means every minute)
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "📥 Cloning the GitHub Repository..."
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker Image..."
                sh '''
                docker build -t $DOCKERHUB_USERNAME/jenkinsdemo:latest .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "☁️ Pushing Docker Image to Docker Hub..."
                sh '''
                docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD
                docker push $DOCKERHUB_USERNAME/jenkinsdemo:latest
                '''
            }
        }

        stage('Deploy to Server') {
            steps {
                echo "🚀 Deploying to Server..."
                sh '''
                ssh -o StrictHostKeyChecking=no ubuntu@$SERVER_IP '
                docker pull $DOCKERHUB_USERNAME/jenkinsdemo:latest
                docker stop jenkinsdemo || true
                docker rm jenkinsdemo || true
                docker run -d --name jenkinsdemo -p 3000:3000 $DOCKERHUB_USERNAME/jenkinsdemo:latest
                '
                '''
            }
        }
    }
}

