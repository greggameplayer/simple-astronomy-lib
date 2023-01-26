pipeline {
    agent {
        kubernetes {
            containerTemplate {
                name 'maven'
                image 'maven:3.8.4-openjdk-17-slim'
                command 'sleep'
                args '99d'
            }
            defaultContainer 'maven'
        }
    }

    environment {
        DOCKER_REGISTRY = credentials('DOCKER_REGISTRY')
        DOCKER_USER = credentials('DOCKER_USER')
        DOCKER_PASSWORD = credentials('DOCKER_PASSWORD')
    }

    stages {
        stage('build') {
            steps {
                sh '''
                mvn clean package -DskipTests
                '''
            }
        }
        stage('test') {
            steps {
                sh '''
                mvn test surefire-report:report
                '''
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('main-sonar') {
                    sh "mvn verify sonar:sonar"
                }
            }
        }
        stage('Docker build & push') {
            steps {
                script {
                    docker.withRegistry('https://$DOCKER_REGISTRY', 'docker-registry') {
                        docker.build('simple-astronomy').push('0.3.0')
                    }
                }
            }
        }
    }

    post {
        success {
            junit '**/target/surefire-reports/TEST-*.xml'
            archiveArtifacts 'target/*.jar'
            step( [ $class: 'JacocoPublisher' ] )
        }
        cleanup {
            cleanWs deleteDirs: true
        }
    }
}
