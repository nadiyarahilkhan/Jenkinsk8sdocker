pipeline {
    agent any

    environment {
        K8S_NAMESPACE = 'default' // Kubernetes namespace
        MANIFEST_FILE = 'kubernetes-manifest.yaml' // Kubernetes manifest file
        DOCKER_IMAGE = env.DOCKER_BFLASK_IMAGE  // Fallback Docker image
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

                    // Create Kubernetes secret for Docker registry
                    sh """
                    kubectl create secret docker-registry regcred \
                        --namespace ${K8S_NAMESPACE} \
                        --docker-username=\$DOCKER_USERNAME \
                        --docker-password=\$DOCKER_PASSWORD \
                        --docker-server=docker.io \
                        --dry-run=client -o yaml | kubectl apply -f -
                    """
                }

                // Apply Kubernetes manifest
                withCredentials([file(credentialsId: '00d78077-0b4f-4bfb-9099-4973a46115c8', variable: 'KUBECONFIG')]) {
                    script {
                        sh """
                        sed \
                            -e "s|{{NAMESPACE}}|${K8S_NAMESPACE}|g" \
                            -e "s|{{PULL_IMAGE}}|${DOCKER_IMAGE}|g" \
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
