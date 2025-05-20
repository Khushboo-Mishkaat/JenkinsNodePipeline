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
                    sh """
                    echo "🔧 Using PEM File: ${EC2_PEM_KEY}"
                    chmod 400 ${EC2_PEM_FILE}
                    
                    ssh -o StrictHostKeyChecking=no -i ${EC2_PEM_KEY} ubuntu@${SERVER_IP} << EOF
                        echo "✅ Connected to EC2 Server: ${SERVER_IP}"
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
