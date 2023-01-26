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
        stage('Install docker') {
            steps {
                sh '''
                apt-get update
                apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
                mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update
                apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                service docker start
                '''
            }
        }
        stage('Docker build & push') {
            steps {
                sh '''
                docker login $DOCKER_REGISTRY -u $DOCKER_USER -p $DOCKER_PASSWORD
                docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_REGISTRY/simple-astronomy:0.3.0 --push .
                '''
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
