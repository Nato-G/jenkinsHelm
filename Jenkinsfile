pipeline {
    agent any
    environment {
        REGITRY = "natog/microservice"
        IMAGE_TAG = "latest"
        // registryCredential = 'dockerHubAccount'
        DOCKERHUB_CREDENTIALS = withCredentials('dockerhubuser')
        KUBE_NAMESPACE = "jenkins"
        KUBE_DEPLOYMENT_NAME = "microservice-deployment"
        KUBE_SA_CREDENTIALS = "f63a7a71-dfb7-4a2e-8661-566dd0fadacd"
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '20', daysToKeepStr: '5' ))
    }
    stages {
        stage('Pull Code') {
            steps {
                git url: 'https://github.com/Nato-G/jenkinsHelm.git', credentialsId: 'githubuser', branch: 'main'
            }
        }
        stage('run tests') {
            steps {
                script {
                    sh 'echo run tests'            
                }
            }
        }
        stage('build image') {
            steps {
                sh 'docker build -t ${REGISTRY}:${IMAGE_TAG} .'
            }
        } 
        stage('login') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PWS | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('push') {
            steps {
                sh 'docker push natog/microservice'
            }
        }
        stage('deploy image') {
            steps {
                script {
                    withCredentials([kubernetesServiceAccountCredentials(credentialsId: KUBE_SA_CREDENTIALS, namespace: KUBE_NAMESPACE)]) {
                    sh "kubectl config use-context minikube"
                    sh "kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} microservice=${registry}:latest -n ${KUBE_NAMESPACE}"
                    sh "kubectl rollout status deployment/${KUBE_DEPLOYMENT_NAME} -n ${KUBE_NAMESPACE}"
                    } 
                }
            }
        }
    }
}



            // steps {
            //     script {
            //         docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
            //             def appImage = docker.build(registry, '.')
            //             appImage.push()
            //         }
            //     }    
            // }