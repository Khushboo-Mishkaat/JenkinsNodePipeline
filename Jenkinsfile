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

        stage('Build') {
            steps {
                echo "🔧 Building the Application..."
                sh 'echo "Simulating Build... (Replace with actual build command)"'
            }
        }

        stage('Test') {
            steps {
                echo "✅ Running Tests..."
                sh 'echo "Simulating Tests... (Replace with actual test command)"'
            }
        }

        stage('Docker Build and Push') {
            steps {
                echo "📦 Building Docker Image..."
                sh '''
                docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD
                docker build -t $DOCKERHUB_USERNAME/jenkinsdemo:latest .
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
                docker run -d --name jenkinsdemo -p 80:80 $DOCKERHUB_USERNAME/jenkinsdemo:latest
                '
                '''
            }
        }
    }
}

