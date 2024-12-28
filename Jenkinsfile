pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'docker build -t my-flask-app .'
                sh 'docker tag my-flask-app $DOCKER_BFLASK_IMAGE'
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin docker.io"
                    sh 'docker push $DOCKER_BFLASK_IMAGE'
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
