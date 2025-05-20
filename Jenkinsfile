pipeline {
    agent any

    environment {
        // Docker Hub credentials
        DOCKER_HUB_CREDS = credentials('DOCKERHUB_CREDENTIALS')
        // PEM File Path for SSH
        PEM_FILE = '/var/lib/jenkins/.ssh/Project_Veroke.pem' // Path to your PEM file
        // EC2 server IP
        REMOTE_HOST = credentials('SERVER_IP')
        // Docker image name
        IMAGE_NAME = 'khushboo053/jenkinsdemo'
        // Docker Hub Username
        DOCKERHUB_USERNAME = 'khushboo053'
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
                script {
                    echo "🔧 Building Docker Image..."
                    sh """
                    docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} .
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "🚀 Logging into Docker Hub..."
                    sh """
                    echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin
                    docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "🚀 Deploying to EC2..."
                    sh """
                    echo "🔧 Using PEM File: ${PEM_FILE}"
                    chmod 400 ${PEM_FILE}
                    
                    ssh -o StrictHostKeyChecking=no -i ${PEM_FILE} ubuntu@${REMOTE_HOST} << 'EOF'
                        echo "✅ Connected to EC2 Server: ${REMOTE_HOST}"
                        docker pull ${DOCKERHUB_USERNAME}/jenkinsdemo:main
                        docker stop jenkinsdemo || true
                        docker rm jenkinsdemo || true
                        docker run -d --name jenkinsdemo -p 3000:3000 ${DOCKERHUB_USERNAME}/jenkinsdemo:main
                        echo "🚀 Application Deployed Successfully!"
EOF
                    """
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
