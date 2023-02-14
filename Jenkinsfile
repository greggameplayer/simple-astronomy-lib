pipeline {
    agent {
        kubernetes {
            defaultContainer 'maven'
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: maven
                image: maven:3.8.4-openjdk-17-slim
                command:
                  - sleep
                args:
                  - 99d
              - name: docker
                image: docker:dind
                command:
                  - /usr/local/bin/dockerd-entrypoint.sh
                args:
                  - dockerd
                tty: true
                securityContext: 
                  privileged: true
            '''
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
        stage('Nexus push') {
            steps {
                nexusPublisher nexusInstanceId: 'main', nexusRepositoryId: 'maven-releases', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: 'target/*']], mavenCoordinate: [artifactId: '${POM_ARTIFACTID}', groupId: '${POM_GROUPID}', packaging: '${POM_PACKAGING}', version: '${POM_VERSION}']]]
            }
        }
        stage('Docker build & push') {
            steps {
                container('docker') {
                    script {
                        docker.withRegistry('https://$DOCKER_REGISTRY', 'docker-registry') {
                            sh '''
                            docker buildx create --name mybuilder
                            docker buildx use mybuilder
                            docker buildx inspect --bootstrap
                            docker buildx build --platform linux/amd64,linux/arm64 -t $DOCKER_REGISTRY/simple-astronomy:0.3.0 --push .
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            junit '**/target/surefire-reports/TEST-*.xml'
            archiveArtifacts 'target/*.jar'
            step([$class: 'JacocoPublisher'])
        }
        cleanup {
            cleanWs deleteDirs: true
        }
    }
}
