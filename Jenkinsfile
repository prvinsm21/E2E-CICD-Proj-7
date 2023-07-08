pipeline {
    agent any
    tools {
        jdk 'jdk11'
        maven 'maven3'
    }
    environment {
        DOCKERHUB_USERNAME = "prvinsm21"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKERIMAGE_NAME = "prvinsm21/cofeeshop-site:${BUILD_NUMBER}"
    }

    stages {
        stage ('Git Checkout') {
            steps {
                sh 'echo Passed'
            }
        }
        stage ('Build Artifacts') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }
        stage ('Test-JUnit') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }
        stage ('Integration testing') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage ('Static Code analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar-api'){
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        stage ('Quality Gate Check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-api'
                }
            }
        }
        stage ('Upload jar file to Nexus') {
            steps{
                script{
                    def readPomVersion = readMavenPom file: 'pom.xml'
                    
                    nexusArtifactUploader artifacts: 
                    [
                        [
                            artifactId: 'coffeeshop', 
                            classifier: '', 
                            file: 'target/coffeeshop-site.jar', 
                            type: 'jar'
                        ]
                    ], 
                    credentialsId: 'nexus-auth', 
                    groupId: 'com.macko', 
                    nexusUrl: '192.168.29.38:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'coffeeshop-site', 
                    version: "${readPomVersion.version}"
                }
            }
        }
        stage ('Build Docker image') {
            steps {
                sh '''
                   docker build -t ${DOCKERIMAGE_NAME} .
                   docker images 
                '''
            }
        }
        stage ('Trivy Image Scanning') {
            steps {
                sh 'sudo trivy images ${DOCKERIMAGE_NAME} > $WORKSPACE/trivy-image-scan-$BUILD_NUMBER.txt'
            }
        }
        stage ('Push Docker image') {
            steps {
                script {
                    def dockerImage = docker.image("${DOCKERIMAGE_NAME}")
                    docker.withRegistry('https://index.docker.io/v1/', "dockerhub") {
                    dockerImage.push()
                    }
                }
            }
        }

    }
}