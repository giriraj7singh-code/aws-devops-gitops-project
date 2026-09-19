pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = 'devops-api'
        IMAGE_TAG = '1.0.0'
        COMPOSE_PROJECT_NAME = 'aws-devops-gitops-project'
    }

    stages {
        stage('Verify Tools') {
            steps {
                sh '''
                    java -version
                    mvn -version
                    docker version
                    docker compose version
                '''
            }
        }

        stage('Test') {
            steps {
                dir('app') {
                    sh 'mvn -B clean test'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'app/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                dir('app') {
                    sh 'mvn -B -DskipTests package'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ./app'
            }
        }

        stage('Security Scan') {
            steps {
                sh '''
                    trivy image \
                      --scanners vuln \
                      --severity HIGH,CRITICAL \
                      --ignore-unfixed \
                      --exit-code 1 \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    docker compose \
                      -p ${COMPOSE_PROJECT_NAME} \
                      up -d --no-build
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    for attempt in $(seq 1 12); do
                        if curl -fsS http://127.0.0.1/health; then
                            echo
                            echo "Application is healthy"
                            exit 0
                        fi

                        echo "Waiting for application: attempt ${attempt}/12"
                        sleep 5
                    done

                    docker compose -p ${COMPOSE_PROJECT_NAME} ps
                    docker compose -p ${COMPOSE_PROJECT_NAME} logs --tail=100
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'app/target/*.jar',
                             fingerprint: true
        }

        always {
            sh 'docker compose -p ${COMPOSE_PROJECT_NAME} ps || true'
        }
    }
}
