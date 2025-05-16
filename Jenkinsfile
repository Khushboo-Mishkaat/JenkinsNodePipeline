pipeline {
    agent any
    environment {
        SERVER_IP = credentials('SERVER_IP')          // Your EC2 Server IP (Stored as Secret Text in Jenkins)
        DOCKERHUB_CREDENTIALS = credentials('DOCKERHUB_CREDENTIALS') // Your DockerHub Credentials (Username/Password)
    }
    stages {
        stage('Checkout Code') {
            steps {
                echo "📥 Cloning the GitHub Repository..."
                checkout scm  // Pulls latest code from your GitHub repo
            }
        }

        stage('Build') {
            steps {
                echo "🔧 Building the Application..."
                sh 'echo "Building JenkinsDemo Application..."'
            }
        }

        stage('Test') {
            steps {
                echo "✅ Running Tests..."
                sh 'echo "Running Tests for JenkinsDemo..."'
            }
        }

        stage('Docker Build & Push') {
            steps {
                echo "🐳 Building and Pushing Docker Image..."
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh """
                    docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}
                    docker build -t ${DOCKERHUB_USERNAME}/jenkinsdemo:latest .
                    docker push ${DOCKERHUB_USERNAME}/jenkinsdemo:latest
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo "🚀 Deploying to EC2..."
                withCredentials([file(credentialsId: 'EC2_PEM_KEY', variable: 'EC2_PEM_KEY')]) {
                    sh """
                    chmod 400 ${EC2_PEM_KEY}
                    ssh -o StrictHostKeyChecking=no -i ${EC2_PEM_KEY} ubuntu@${env.SERVER_IP} '
                        docker pull ${DOCKERHUB_USERNAME}/jenkinsdemo:latest &&
                        docker stop jenkinsdemo || true &&
                        docker rm jenkinsdemo || true &&
                        docker run -d --name jenkinsdemo -p 80:80 ${DOCKERHUB_USERNAME}/jenkinsdemo:latest
                    '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build, Test, and Deploy completed successfully for JenkinsDemo!"
        }
        failure {
            echo "❌ Pipeline failed. Check the console for details."
        }
    }
}

