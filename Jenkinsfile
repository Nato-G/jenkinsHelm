pipeline {
    agent any
    environment {
        registry = "natog/microservice"
        registryCredential = 'dockerHubAccount'
        KUBE_NAMESPACE = "jenkins"
        KUBE_DEPLOYMENT_NAME = "microservice-deployment"
        KUBE_SA_CREDENTIALS = "f63a7a71-dfb7-4a2e-8661-566dd0fadacd"
        DOCKER_PATH = "/usr/bin"
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
                    // sh '/usr/bin/docker --version'
            
                }
            }
        }
        stage('check distribution') {
            steps {
                script {
                    sh '''
                    if [ -f /etc/os-release ]; then
                        cat /etc/os-release
                    elif [ -f /etc/issue ]; then
                        cat /etc/issue
                    else
                        echo "Unable to determine the Linux distribution"
                    fi
                    '''
                }
            }
        }
        stage('install docker') {
            steps {
                script{
                    sh '''
                    apt-get update
                    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    apt-get update
                    apt-get install -y docker-ce docker-ce-cli containerd.io
                    usermod -aG docker jenkins
                    '''
                }
            }
        }
        stage('build and push image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                        def appImage = docker.build(registry, '.')
                        appImage.push()
                    }
                }    
            }
        }
        stage('deploy image') {
            steps {
                script {
                    withCredentials([kubernetesServiceAccountCredentials(credentialsId: KUBE_SA_CREDENTIALS, namespace: KUBE_NAMESPACE)]) {
                    sh "kubectl config use-context minikube"
                    sh "kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} microservice=${REGISTRY}:latest -n ${KUBE_NAMESPACE}"
                    sh "kubectl rollout status deployment/${KUBE_DEPLOYMENT_NAME} -n ${KUBE_NAMESPACE}"
                    } 
                }
            }
        }
    }
}
