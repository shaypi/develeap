pipeline {
    agent {
        docker { image 'custom-jenkins-docker:latest'}
    }
    environment {
        AWS_REGION = 'eu-west-1'
        AWS_ACCESS_KEY_ID = credentials('aws-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        ECR_REGISTRY = "160213321344.dkr.ecr.eu-west-1.amazonaws.com"
        ECR_REPOSITORY = "develeap"
        TAG = "jenkins-build-${BUILD_NUMBER}"
    }

    options {
            disableConcurrentBuilds()
            skipDefaultCheckout()
            timestamps()
    }

    triggers {
        GenericTrigger(
                genericVariables: [
                        [key: 'Commit_id', value: '$.pull_request.head.sha', defaultValue: 'None'],
                        [key: 'PR_number', value: '$.number', defaultValue: 'None'],
                        [key: 'Repository', value: '$.pull_request.base.repo.full_name', defaultValue: 'None'],
                        [key: 'User', value: '$.pull_request.user.login', defaultValue: 'None'],
                        [key: 'action', value: '$.action', defaultValue: 'None'],
                ],

                causeString: 'Triggered on $PR_number',
                token: 'develeap',
                printContributedVariables: true,
                printPostContent: true,
                silentResponse: false,
                regexpFilterText: '$action',
                regexpFilterExpression: '(opened|reopened|synchronize)'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/shaypi/develeap']]])
            }
        }

        stage('Cleanup Docker') {
            steps {
                script {
                    def exitedContainers = sh(
                        script: 'docker ps -a -f status=exited -q',
                        returnStdout: true
                    ).trim()

                    if (exitedContainers) {
                        // Run docker rm with the list of container IDs
                        sh "docker rm ${exitedContainers}"
                    } else {
                        echo "No containers to remove."
                    }

                    // Remove unused Docker images older than 1 hour
                    sh 'docker image prune -a --force --filter "until=1h"'
                }
            }
        }

        stage('Install Python 3, pip, and pipenv, third-party dependencies, and AWS CLI') {
            steps {
                script {
                    sh '''
                        # Install Python 3, pip, and pipenv
                        apt-get update && \
                        apt-get install -y python3 python3-pip && \
                        pip3 install --user pipenv && \
                        pip3 install Werkzeug flask && \
                        pip3 install --pre black
                        
                        # Install third-party dependencies
                        apt-get update && apt-get install -y zip curl

                        # Install AWS CLI
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip -o awscliv2.zip
                        ./aws/install
                        apt-get update
                        apt-get dist-upgrade -y
                        apt-get install -y less
                    '''
                }
            }
        }

        stage('Code Formatting and Lint') {
            steps {
                dir('app') {
                    script {
                        sh '''
                            # Code Formatting
                            black .
                            
                            # Lint
                            black --check .
                        '''
                    }
                }
            }
        }

        stage('Configure AWS credentials') {
            steps {
                sh 'mkdir ~/.aws'
                sh 'echo "[default]" > ~/.aws/credentials'
                sh 'echo "aws_access_key_id=${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials'
                sh 'echo "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials'
                sh 'echo "[default]" > ~/.aws/config'
                sh 'echo "region=${AWS_REGION}" >> ~/.aws/config'
            }
        }

        stage('Connect to ECR') {
            steps {
                sh 'aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY'
            }
        }
        
        stage('Build, Tag and, Push Image') {
            steps {
                sh "docker build -t develeap app/"
                sh "docker tag develeap $ECR_REGISTRY/$ECR_REPOSITORY:${TAG}"
                sh "docker push $ECR_REGISTRY/$ECR_REPOSITORY:${TAG}"
                sh "docker tag develeap $ECR_REGISTRY/$ECR_REPOSITORY:develeap-${env.BUILD_NUMBER}"
                sh "docker push $ECR_REGISTRY/$ECR_REPOSITORY:develeap-${env.BUILD_NUMBER}"
            }
        }

        // stage('debug') {
        //     steps {
        //         sh 'sleep 60000'
        //     }
        // }

        // stage('Connect to k8s cluster') {
        //     steps {
        //         sh 'aws eks --region eu-west-1 update-kubeconfig --name develeap'
        //     }
        // }

        // stage('Create namespace') {
        //     steps {
        //         script {
        //             sh 'kubectl create ns develeap --dry-run=client -o yaml | kubectl apply -f -'
        //         }
        //     }
        // }

        // stage('Deploy develeap app') {
        //     steps {
        //         script {
        //             sh 'kubectl apply -f develeap.yaml'
        //         }
        //     }
        // }
    }
}
