pipeline {
    agent any

    environment {
        // Docker Hub credentials
        DOCKER_HUB_CREDS = credentials('DOCKERHUB_CREDENTIALS')
        // GitHub credentials
        GIT_CREDENTIALS = credentials('GITHUB_CREDENTIALS')
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
                git credentialsId: "${GIT_CREDENTIALS}", url: 'https://github.com/Khushboo-Mishkaat/JenkinsNodePipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    // Save private key to temporary file
                    writeFile file: 'ec2-key.pem', text: "${EC2_KEY}"
                    sh 'chmod 400 ec2-key.pem'

                    // Deploy via SSH
                    sh """
                        ssh -o StrictHostKeyChecking=no -i ec2-key.pem ubuntu@${REMOTE_HOST} << EOF
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

    post {
        always {
            // Cleanup
            sh 'rm -f ec2-key.pem'
        }
    }
}
