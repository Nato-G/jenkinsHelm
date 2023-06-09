pipeline {
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhubuser'
        DOCKERHUB_REPO = "natog/microservice"
        DOCKERHUB_USERNAME = 'natog'
        DOCKER_IMAGE = "${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}"
        IMAGE_TAG = "latest"        
        KUBE_NAMESPACE = "jenkins"
        KUBE_DEPLOYMENT_NAME = "microservice-deployment"
        KUBE_SA_CREDENTIALS = "f63a7a71-dfb7-4a2e-8661-566dd0fadacd"

    }
    
    agent {
        kubernetes {
            yamlFile 'jenkins-pod.yaml'
        }  
    } 
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '20', daysToKeepStr: '5' ))
    }

    stages {
        stage('Print PATH') {
            steps {
                sh 'echo $PATH'
            }
        }
        stage('Check Docker socket') {
            steps {
                sh 'echo $DOCKER_HOST'
            }
        }    
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
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKERHUB_CREDENTIALS}") {
                        def customImage = docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                    }
                }
            }
        }
        stage('push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKERHUB_CREDENTIALS}") {
                    docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").build("-t ${DOCKER_IMAGE}:${IMAGE_TAG} -f Dockerfile .")
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }
        stage('deploy image') {
            steps {
                script {
                    withCredentials([kubernetesServiceAccountCredentials(credentialsId: KUBE_SA_CREDENTIALS, namespace: KUBE_NAMESPACE)]) {
                        sh(script: """
                            kubectl config use-context minikube
                            kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} microservice=${registry}:latest -n ${KUBE_NAMESPACE}
                            kubectl rollout status deployment/${KUBE_DEPLOYMENT_NAME} -n ${KUBE_NAMESPACE}
                        """)
                    } 
                }
            }
        }
    }
}


            //   - sh
    //   - -c
    //   - |
    //     dockerd \
    //     --host=unix:///var/run/docker.sock \
    //     --host=tcp://0.0.0.0:2375 \
    //     --tls=false \
    //     --storage-driver=overlay2 \
    //     --bip=10.0.0.1/24 \
    //     --log-level=debug






            // containerTemplate {
            //     name 'docker'
            //     image 'docker:20.10.10'
            //     command 'sleep'
            //     args '9999' 
            //     ttyEnabled true
            //     privileged true
            //     // volumeMounts [name: 'dockersock', mountPath: '/var/run/docker.sock']
            //     // volumes [ name: 'dockersock', hostPath: [path: '/var/run/docker.sock'] ]
            // }