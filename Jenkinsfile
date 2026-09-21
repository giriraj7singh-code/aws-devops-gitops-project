pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        IMAGE_NAME = 'girirajs7/devops-api'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {
        stage('Verify Tools') {
            steps {
                sh '''
                    java -version
                    mvn -version
                    docker version
                '''
            }
        }

        stage('Test') {
            steps {
                dir('app') {
                    sh 'mvn -B clean verify'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'app/target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'sonar-token',
                        variable: 'SONAR_TOKEN'
                    )
                ]) {
                    dir('app') {
                        sh '''
                            mvn -B \
                              org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                              -Dsonar.token="$SONAR_TOKEN" \
                              -Dsonar.qualitygate.wait=true \
                              -Dsonar.qualitygate.timeout=300
                        '''
                    }
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
        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKERHUB_TOKEN" |
                          docker login \
                            --username "$DOCKERHUB_USERNAME" \
                            --password-stdin

                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'app/target/*.jar',
                             fingerprint: true
        }

        always {
            sh 'docker logout || true'
        }
    }
}
