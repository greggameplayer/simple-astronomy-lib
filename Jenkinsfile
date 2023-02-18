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
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "https"
        NEXUS_URL = "nexus.gregsvc.fr"
        NEXUS_REPOSITORY = "maven-releases"
        NEXUS_CREDENTIAL_ID = "nexus-creds"
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
        stage('static tests analysis') {
            steps {
                sh '''
                mvn checkstyle:checkstyle spotbugs:check
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
                script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                                nexusVersion: NEXUS_VERSION,
                                protocol: NEXUS_PROTOCOL,
                                nexusUrl: NEXUS_URL,
                                groupId: pom.groupId,
                                version: pom.version,
                                repository: NEXUS_REPOSITORY,
                                credentialsId: NEXUS_CREDENTIAL_ID,
                                artifacts: [
                                        [artifactId: pom.artifactId,
                                         classifier: '',
                                         file: artifactPath,
                                         type: pom.packaging],
                                        [artifactId: pom.artifactId,
                                         classifier: '',
                                         file: "pom.xml",
                                         type: "pom"]
                                ]
                        );
                    } else {
                        error "*** File: ${artifactPath}, could not be found";
                    }
                }
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
            recordIssues enabledForFailure: true, tools: [mavenConsole(), java(), javaDoc()]
            recordIssues enabledForFailure: true, tools: [checkStyle(), spotBugs()]
        }
        cleanup {
            cleanWs deleteDirs: true
        }
    }
}
