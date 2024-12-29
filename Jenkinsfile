pipeline {
    agent any

    environment {
        K8S_NAMESPACE = 'default' // Kubernetes namespace
        MANIFEST_FILE = 'kubernetes-manifest.yaml' // Kubernetes manifest file
        GOOGLE_APPLICATION_CREDENTIALS = credentials('7513358a-a8d8-4424-af46-a366634f798a') // Service account key for GCP
    }

    stages {
        stage('Build') {
            steps {
                sh 'docker build -t my-flask-app .'
                sh 'docker tag my-flask-app $DOCKER_BFLASK_IMAGE'
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDS}", 
                                                 passwordVariable: 'DOCKER_PASSWORD', 
                                                 usernameVariable: 'DOCKER_USERNAME')]) {
                    // Push Docker image
                    sh """
                    echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin docker.io
                    docker push $DOCKER_BFLASK_IMAGE
                    """
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform for GCP
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Generate Terraform execution plan for GCP resources
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform plan to provision GCP infrastructure
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                withCredentials([file(credentialsId: '00d78077-0b4f-4bfb-9099-4973a46115c8', variable: 'KUBECONFIG')]) {
                    script {
                        sh """
                        sed \
                            -e "s|{{NAMESPACE}}|${K8S_NAMESPACE}|g" \
                            -e "s|{{PULL_IMAGE}}|${DOCKER_BFLASK_IMAGE}|g" \
                            ${MANIFEST_FILE} \
                        | kubectl apply -f -
                        """
                    }
                }
            }
        }

        stage('Run and Test') {
            steps {
                script {
                    sh 'docker run -dit --name test $DOCKER_BFLASK_IMAGE'
                    sh 'docker exec -i test date'
                    sh 'docker stop test'
                    sh 'docker rm test'
                }
            }
        }
    }
}
