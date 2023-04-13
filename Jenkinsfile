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
            // inheritFrom 'nato-docker-test'
            containerTemplate {
                name: 'docker'
                image: 'docker:20.10.10'
                command: 'sleep'
                args: '9999' 
                ttyEnabled: true
                privileged: true
                volumeMounts: [name: 'dockersock', mountPath: '/var/run/docker.sock']
                volumes: [ name: 'dockersock', hostPath: [path: '/var/run/docker.sock']] 
            }
        }    
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
        // stage('build image') {
        //     steps {
        //         sh 'docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .'
        //     }
        // } 
        stage('build image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKERHUB_CREDENTIALS}") {
                        def customImage = docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                    }
                }
            }
            // steps {
            //     sh 'echo $DOCKERHUB_CREDENTIALS_PWS | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            // }
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
            // steps {
            //     sh 'docker push natog/microservice'
            // }
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



            // steps {
            //     script {
            //         docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
            //             def appImage = docker.build(registry, '.')
            //             appImage.push()
            //         }
            //     }    
            // }


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



//             yaml """
// kind: Pod
// spec:
//   containers:
//   - name: docker
//     image: docker:20.10.10
//     imagePullPolicy: Always
//     command:
//       - cat
//     securityContext:
//       privileged: true
//     tty: true
//     volumeMounts:
//       - name: dockersock
//         mountPath: /var/run/docker.sock
//   volumes:
//     - name: dockersock
//       hostPath: 
//         path: /var/run/docker.sock
// """