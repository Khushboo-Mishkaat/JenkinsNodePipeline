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
                echo "DEBUG: Using DockerHub Credentials ID: DOCKERHUB_CREDENTIALS"
                docker build -t jenkinsdemo:${BRANCH_NAME} .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "☁️ Pushing Docker Image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                    echo "DEBUG: Logging into DockerHub..."
                    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                    docker tag jenkinsdemo:${BRANCH_NAME} $DOCKER_USERNAME/jenkinsdemo:${BRANCH_NAME}
                    docker push $DOCKER_USERNAME/jenkinsdemo:${BRANCH_NAME}
                    '''
                }
            }
        }

        stage('Deploy to Server') {
            when {
                branch 'main'
            }
            steps {
                echo "🚀 Deploying to Server (Main Branch Only)..."
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                    echo "DEBUG: Using DockerHub Credentials ID: DOCKERHUB_CREDENTIALS"
                    ssh -i $EC2_PEM_KEY -o StrictHostKeyChecking=no ubuntu@$SERVER_IP '
                    if docker pull $DOCKER_USERNAME/jenkinsdemo:main; then
                        docker stop jenkinsdemo || true
                        docker rm jenkinsdemo || true
                        docker run -d --name jenkinsdemo -p 3000:3000 $DOCKER_USERNAME/jenkinsdemo:main
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
}
