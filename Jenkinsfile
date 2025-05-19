pipeline {
    agent any

    environment {
        SERVER_IP = credentials('SERVER_IP')
        DOCKERHUB_CREDENTIALS = credentials('DOCKERHUB_CREDENTIALS')
        EC2_PEM_KEY = credentials('EC2_PEM_KEY')
    }

    triggers {
        pollSCM('H/1 * * * *')
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
                echo "DEBUG: DockerHub Username: ${DOCKERHUB_CREDENTIALS_USR}"
                docker build -t ${DOCKERHUB_CREDENTIALS_USR}/jenkinsdemo:${BRANCH_NAME} .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "☁️ Pushing Docker Image to Docker Hub..."
                sh '''
                docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}
                docker push ${DOCKERHUB_CREDENTIALS_USR}/jenkinsdemo:${BRANCH_NAME}
                '''
            }
        }

        stage('Deploy to Server') {
            when {
                branch 'main'
            }
            steps {
                echo "🚀 Deploying to Server (Main Branch Only)..."
                sh '''
                echo "DEBUG: DockerHub Username: ${DOCKERHUB_CREDENTIALS_USR}"
                ssh -i $EC2_PEM_KEY -o StrictHostKeyChecking=no ubuntu@$SERVER_IP '
                if docker pull ${DOCKERHUB_CREDENTIALS_USR}/jenkinsdemo:main; then
                    docker stop jenkinsdemo || true
                    docker rm jenkinsdemo || true
                    docker run -d --name jenkinsdemo -p 3000:3000 ${DOCKERHUB_CREDENTIALS_USR}/jenkinsdemo:main
                else
                    echo "❌ Failed to pull the Docker image. Please check the image name or DockerHub credentials."
                    exit 1
                fi
                '
                '''
            }
        }
    }
}
