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
                    sh "mvn verify sonar:sonar -Dsonar.projectKey=greggameplayer_simple-astronomy-lib"
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
