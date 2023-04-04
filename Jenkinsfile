pipeline {
    agent any
    environment {
        registry = "natog/microservice"
        registryCredential = 'docker_hub'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '20', daysToKeepStr: '5' ))
    }
    stages {
        stage('Pull Code') {
            steps {
                git url: 'https://github.com/Nato-G/jenkinsHelm.git', credentialsId: 'githubuser'
            }
        }
        stage('run tests') {
            steps {
                script {
                    sh 'echo run tests'
                }
            }
        }
        stage('build and push image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                        def appImage = docker.build(registry)
                        appImage.push()
                }
            }
        }
        stage('deploy image') {
            steps {
                script {
                    sh '''
                        kubectl config use-context minikube
                        kubectl set image deployment/microservice-deployment microservice=${registry}:latest
                        kubectl rollout status deployment/microservice-deployment
                    '''
                }
            }
        }
    }
}



