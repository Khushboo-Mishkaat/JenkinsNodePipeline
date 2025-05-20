pipeline {
    agent any

    environment {
        // PEM File Path for SSH
        PEM_FILE = '/var/lib/jenkins/.ssh/Project_Veroke.pem' 
        // EC2 server IP
        SERVER_IP = credentials('SERVER_IP')
        // Docker image name
        IMAGE_NAME = 'khushboo053/jenkinsdemo'
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
                    sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "🚀 Logging into Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}
                        """
                    }
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
                    
                    ssh -o StrictHostKeyChecking=no -i ${PEM_FILE} ubuntu@${SERVER_IP} << 'EOF'
                        echo "✅ Connected to EC2 Server: ${SERVER_IP}"
                        
                        docker pull ${IMAGE_NAME}:${env.BUILD_NUMBER}

                        # Check if the container exists and stop/remove it if it does
                        if [ \$(docker ps -aq -f name=jenkinsdemo) ]; then
                            echo "🛑 Stopping and Removing existing jenkinsdemo container..."
                            docker stop jenkinsdemo || true
                            docker rm jenkinsdemo || true
                        else
                            echo "✅ No existing container named jenkinsdemo found."
                        fi
                        
                        # Run the new container
                        echo "🚀 Running the new Docker container..."
                        docker run -d --name jenkinsdemo -p 3000:3000 ${IMAGE_NAME}:${env.BUILD_NUMBER}
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
