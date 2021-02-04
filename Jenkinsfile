#!/usr/bin/env groovy
@Library(value='jenkins-pipeline-scripts@master', changelog=false) _

String DOCKER_REGISTRY="index.docker.io/v1".trim()
String DOCKER_ORGANISATION="nabla".trim()
String DOCKER_TAG="1.0.11".trim()
String DOCKER_TAG_NEXT="1.0.12".trim()
String DOCKER_NAME="ansible-jenkins-slave-docker".trim()

String DOCKER_REGISTRY_URL="https://${DOCKER_REGISTRY}".trim()
String DOCKER_REGISTRY_URL="https://${DOCKER_REGISTRY}".trim()
String DOCKER_REGISTRY_CREDENTIAL=env.DOCKER_REGISTRY_CREDENTIAL ?: "hub-docker-nabla".trim()
String DOCKER_IMAGE="${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}".trim()

String DOCKER_OPTS_BASIC = getDockerOpts()
String DOCKER_OPTS_COMPOSE = getDockerOpts(isDockerCompose: true, isLocalJenkinsUser: false)

pipeline {
  //agent none
  agent {
    docker {
      image DOCKER_IMAGE
      alwaysPull true
      reuseNode true
      args DOCKER_OPTS_COMPOSE
      label 'molecule'
    }
  }
  parameters {
    string(name: 'DRY_RUN', defaultValue: '--check', description: 'Default mode used to test playbook')
    string(name: 'DOCKER_RUN', defaultValue: '', description: 'Default inventory used to test playbook')
    string(name: 'ANSIBLE_INVENTORY', defaultValue: 'production', description: 'Default inventory used to test playbook')
    string(name: 'TARGET_SLAVE', defaultValue: 'inventory/albandri', description: 'Default server used to test playbook')
    string(name: 'TARGET_PLAYBOOK', defaultValue: 'playbooks/jenkins-slave.yml', description: 'Default playbook to override')
    string(name: 'ANSIBLE_VAULT_PASS', defaultValue: 'test123', description: 'Default vault password to override')
    booleanParam(name: 'CLEAN_RUN', defaultValue: false, description: 'Clean before run')
    booleanParam(name: 'SKIP_LINT', defaultValue: false, description: 'Skip Linter - requires ansible galaxy roles, so it is time consuming')
    booleanParam(name: 'SKIP_DOCKER', defaultValue: false, description: 'Skip Docker - requires image rebuild from scratch')
    booleanParam(name: 'MOLECULE_DEBUG', defaultValue: false, description: 'Enable --debug flag for molecule - does not affect executions of other tests')
    booleanParam(defaultValue: false, description: 'Build only to have package. no test / no docker', name: 'BUILD_ONLY')
    booleanParam(defaultValue: false, description: 'Run molecule tests', name: 'BUILD_MOLECULE')
    booleanParam(defaultValue: true, description: 'Build jenkins docker images', name: 'BUILD_DOCKER')
    booleanParam(defaultValue: false, description: 'Build with sonar', name: 'BUILD_SONAR')
    booleanParam(defaultValue: true, description: 'Test cleaning', name: 'BUILD_CLEANING')
    booleanParam(defaultValue: false, description: 'Test cmdb', name: 'BUILD_CMDB')
    booleanParam(defaultValue: true, description: 'Run sphinx', name: 'BUILD_DOC')
  }
  environment {
    DRY_RUN = "${params.DRY_RUN}".toBoolean()
    CLEAN_RUN = "${params.CLEAN_RUN}".toBoolean()
    DEBUG_RUN = "${params.DEBUG_RUN}".toBoolean()
    //BRANCH_NAME = "${env.BRANCH_NAME}".replaceAll("feature/","")
    //PROJECT_BRANCH = "${env.GIT_BRANCH}".replaceFirst("origin/","")
    //BUILD_ID = "${env.BUILD_ID}"
  }
  options {
    disableConcurrentBuilds()
    //skipStagesAfterUnstable()
    //parallelsAlwaysFailFast() // this is hidding failure and unstable stage
    ansiColor('xterm')
    timeout(time: 360, unit: 'MINUTES')
    timestamps()
  }
  stages {
    stage('Setup') {
      steps {
        script {
          properties(createPropertyList())
          setBuildName("Ansible project description.")

          lock("${params.TARGET_SLAVE}") {
            echo "Lock on ${params.TARGET_SLAVE} released" // we do not have many molecule label
            sh "rm -f *.log || true"
          } // lock
        }
      }
    }
    stage("Ansible pre-commit check") {
      steps {
        script {
          // TODO testPreCommit
          tee("pre-commit.log") {
            sh "#!/bin/bash \n" +
              "whoami \n" +
              "source ./scripts/run-python.sh\n" +
              "pre-commit run -a || true\n" +
              "find . -name 'kube.*' -type f -follow -exec kubectl --kubeconfig {} cluster-info \\; || true\n"
          } // tee
        } // script
      }
    } // stage pre-commit
    stage("Ansible CMDB Report") {
      when {
        expression { params.BUILD_ONLY == false && params.BUILD_CMDB == true }
      }
      steps {
        script {
          runAnsibleCmbd(shell: "./scripts/run-ansible-cmbd.sh")
        } // script
      }
    }
    stage('Documentation') {
      when {
        expression { params.BUILD_ONLY == false && params.BUILD_DOC == true }
      }
      // Creates documentation using Sphinx and publishes it on Jenkins
      // Copy of the documentation is rsynced
      steps {
        script {
          runSphinx(shell: "../scripts/run-python.sh && ./build.sh", targetDirectory: "fusionrisk-ansible/")
        }
      }
    }

    stage('Cleaning tests') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY == false && params.BUILD_CLEANING == true }
      }
      steps {
        script {
          if (JENKINS_URL ==~ /.*aandrieu.*|.*albandri.*|.*test.*|.*localhost.*/ ) {
		        configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: 'ANSIBLE_VAULT_PASS')]) {
		          ansiblePlaybook colorized: true,
		              credentialsId: 'jenkins_unix_slaves',
		              disableHostKeyChecking: true,
		              extras: '-e ansible_python_interpreter="/usr/bin/python2.7"',
		              forks: 5,
		              installation: 'ansible-latest',
		              inventory: "${params.ANSIBLE_INVENTORY}",
		              limit: "${params.TARGET_SLAVE}",
		              playbook: "${params.TARGET_PLAYBOOK}"
		        } // configFileProvider

            echo "Init result: ${currentBuild.result}"
            echo "Init currentResult: ${currentBuild.currentResult}"

          } // JENKINS_URL
        } // script
      } // steps
    } // stage Cleaning tests

    stage('SonarQube analysis') {
      environment {
        SONAR_SCANNER_OPTS = "-Xmx4g"
        SONAR_USER_HOME = "$WORKSPACE"
      }
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_ONLY == false && params.BUILD_SONAR == true }
      }
      steps {
        script {
          withSonarQubeWrapper(verbose: true, 
            skipMaven: true, 
            repository: "ansible-nabla")
        }
      } // steps
    } // stage SonarQube analysis
    stage('Molecule - Java') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_MOLECULE == true && params.BUILD_ONLY == false }
      }
      steps {
        script {

          testAnsibleRole(roleName: "ansiblebit.oracle-java")

        }
      }
    } // stage
    stage('Molecule') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_MOLECULE == true && params.BUILD_ONLY == false }
      }
      //environment {
      //  MOLECULE_DEBUG="${params.MOLECULE_DEBUG ? '--debug' : ' '}"  // syntax: important to have the space ' '
      //}
      parallel {
        stage("administration") {
          steps {
            script {
              testAnsibleRole(roleName: "administration")
            }
          }
        }
        stage("common") {
          steps {
            script {
              testAnsibleRole(roleName: "common")
            }
          }
        }
        stage("security") {
          steps {
            script {
              testAnsibleRole(roleName: "security")
            }
          }
        }
      }
    }
    stage('Molecule parallel') {
      when {
        expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
        expression { params.BUILD_MOLECULE == true && params.BUILD_ONLY == false }
      }
      parallel {
        stage("cleaning") {
          steps {
            script {
              testAnsibleRole(roleName: "cleaning")
            }
          }
        }
        stage("DNS") {
          steps {
            script {
              testAnsibleRole(roleName: "dns")
            }
          }
        }
      }
    }
    stage('Docker') {
      parallel {
        stage('Ubuntu 16.04') {
          when {
            expression { env.BRANCH_NAME ==~ /release\/.+|master|develop/ }
            expression { params.BUILD_ONLY == false && params.BUILD_DOCKER == true }
          }
          steps {
            script {
              if (! params.SKIP_DOCKER) {

                tee('docker-build-ubuntu-16.04.log') {

                  configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: '_')]) {

                    sh 'mkdir -p .ssh/ || true'

                    docker_build_args="--no-cache --pull --build-arg JENKINS_HOME=/home/jenkins --tag 1.0.0"

                    docker.withRegistry("${DOCKER_REGISTRY_URL}", "${DOCKER_REGISTRY_CREDENTIAL}") {
                       withCredentials([
                           [$class: 'UsernamePasswordMultiBinding',
                           credentialsId: DOCKER_REGISTRY_CREDENTIAL,
                           usernameVariable: 'USERNAME',
                           passwordVariable: 'PASSWORD']
                       ]) {
                         def container = docker.build("${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:1.0.0", "${docker_build_args} -f docker/ubuntu16/Dockerfile . ")
                         container.inside {
                           sh 'echo test'
                         }
                         docker.image("${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:1.0.0").withRun("-u root", "/bin/bash") {c ->

                           logs = sh (
                             script: "docker logs ${c.id}",
                             returnStatus: true
                           )

                           echo "LOGS RETURN CODE : ${logs}"
                           if (logs == 0) {
                               echo "LOGS SUCCESS"
                           } else {
                               echo "LOGS FAILURE"
                               sh "exit 1" // this fails the stage
                               //currentBuild.result = 'FAILURE'
                           }
                         } // docker.image
                       } // withCredentials
                    } // withRegistry
                  } // vault
                } // tee
              }
            }
          }
        }
        stage('Ubuntu 18.04') {
          when {
            expression { env.BRANCH_NAME ==~ /release\/.+|master|develop|PR-.*|feature\/.*|bugfix\/.*/ }
            expression { params.BUILD_ONLY == false && params.BUILD_DOCKER == true }
          }
          steps {
            script {
              if (! params.SKIP_DOCKER) {

                tee('docker-build-ubuntu-18.04.log') {

                    try {

                      configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: 'ANSIBLE_VAULT_PASS')]) {

                        sh 'mkdir -p .ssh/ || true'

                        DOCKER_BUILD_ARGS=" --pull --build-arg ANSIBLE_VAULT_PASS=${ANSIBLE_VAULT_PASS}"

                        if (env.CLEAN_RUN == true) {
                          DOCKER_BUILD_ARGS+=" --no-cache"
                        }

                         withCredentials([
                             [$class: 'UsernamePasswordMultiBinding',
                             credentialsId: DOCKER_REGISTRY_CREDENTIAL,
                             usernameVariable: 'USERNAME',
                             passwordVariable: 'PASSWORD']
                         ]) {
                          def container = docker.build("${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}", "${DOCKER_BUILD_ARGS} -f docker/ubuntu18/Dockerfile . ")
                          container.inside {
                            sh 'echo test'
                          }

                          //docker run -i -t --entrypoint /bin/bash ${myImg.imageName()}
                          docker.image("${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}").withRun("-u root --entrypoint='/entrypoint.sh'", "/bin/bash") {c ->
                            logs = sh (
                              script: "docker logs ${c.id}",
                              returnStatus: true
                            )

                            echo "LOGS RETURN CODE : ${logs}"
                            if (logs == 0) {
                                echo "LOGS SUCCESS"
                            } else {
                                echo "LOGS FAILURE"
                                sh "exit 1" // this fails the stage
                                //currentBuild.result = 'FAILURE'
                            }

                          } // docker.image

                        } // withCredentials

                        echo "TODO JUNIT"

                        // TODO
                        //junit "target/jenkins-full-*.xml"
                        //junit "ansible-lint.xml, pylint-junit-result.xml"

                      } // vault configFileProvider

                    } catch (exc) {
                       echo 'Error: There were errors in tests. '+exc.toString()
                       currentBuild.result = 'UNSTABLE'
                       logs = "FAIL" // make sure other exceptions are recorded as failure too
                       error 'There are errors in tests'
                    } finally {
                       echo "finally"
                    } // finally

                    cst = sh (
                      script: "bash scripts/docker-test.sh ${DOCKER_NAME} ${DOCKER_TAG_NEXT}",
                      returnStatus: true
                    )

                    echo "CONTAINER STRUCTURE TEST RETURN CODE : ${cst}"
                    if (cst == 0) {
                        echo "CONTAINER STRUCTURE TEST SUCCESS"
                    } else {
                        echo "CONTAINER STRUCTURE TEST FAILURE"
                        currentBuild.result = 'UNSTABLE'
                    }

                } // tee

              }
            }
          }
        }
        stage('Sample project') {
          when {
            expression { BRANCH_NAME ==~ /(release|master|develop)/ }
          }
          steps {
            script {

              if (JENKINS_URL ==~ /https:\/\/albandrieu.*\/jenkins\/|https:\/\/todo.*\/jenkins\// ) {
                echo "JENKINS is supported"
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                  build job:'nabla-servers-bower-sample/master', propagate: false, wait: true
                }
              } // JENKINS_URL

            }
          }
        } // stage Sample project
      }
    }
  }
  post {
    always {
      node('molecule') {

        withLogParser(failBuildOnError:false, unstableOnWarning: false)

      } // node
      archiveArtifacts artifacts: "*.log, .scannerwork/*.log, roles/*.log, target/ansible-lint*", onlyIfSuccessful: false, allowEmptyArchive: true
    }
    //cleanup {
    //  wrapCleanWsOnNode()
    //} // cleanup
  } // post
}
