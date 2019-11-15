#!/usr/bin/env groovy
@Library('nabla-pipeline-scripts') _

/*
 * Fusion Risk Ansible
 *
 * Test Ansible Playbooks by: ansible-lint, ansible-playbook on docker images
 */

def DOCKER_REGISTRY="docker.hub"
def DOCKER_ORGANISATION="nabla"
def DOCKER_TAG="1.0.1"
def DOCKER_TAG_NEXT="1.0.2"
def DOCKER_NAME="ansible-jenkins-slave"

def DOCKER_REGISTRY_URL="https://${DOCKER_REGISTRY}"
def DOCKER_REGISTRY_CREDENTIAL='jenkins'
def DOCKER_IMAGE="${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}"

def DOCKER_OPTS = [
  '--dns-search=nabla.mobi',
  '-v /etc/passwd:/etc/passwd:ro ',
  '-v /etc/group:/etc/group:ro ',
  '--entrypoint=\'\'',
].join(" ")

pipeline {
  agent none
  parameters {
    string(name: 'DRY_RUN', defaultValue: '--check', description: 'Default mode used to test playbook')
    string(name: 'DOCKER_RUN', defaultValue: '', description: 'Default inventory used to test playbook')
    string(name: 'ANSIBLE_INVENTORY', defaultValue: 'production', description: 'Default inventory used to test playbook')
    string(name: 'TARGET_SLAVE', defaultValue: 'albandri', description: 'Default server used to test playbook')
    string(name: 'TARGET_PLAYBOOK', defaultValue: 'jenkins-slave.yml', description: 'Default playbook to override')
    string(name: 'ANSIBLE_VAULT_PASS', defaultValue: 'test123', description: 'Default vault password to override')
    booleanParam(name: 'CLEAN_RUN', defaultValue: false, description: 'Clean before run')
    booleanParam(name: 'SKIP_LINT', defaultValue: true, description: 'Skip Linter - requires ansible galaxy roles, so it is time consuming')
    booleanParam(name: 'SKIP_DOCKER', defaultValue: false, description: 'Skip Docker - requires image rebuild from scratch')
    booleanParam(name: 'MOLECULE_DEBUG', defaultValue: false, description: 'Enable --debug flag for molecule - does not affect executions of other tests')
  }
  environment {
    JENKINS_CREDENTIALS = 'jenkins-ssh'
    ANSIBLE_VAULT_PASS = "${params.ANSIBLE_VAULT_PASS}"
    DRY_RUN = "${params.DRY_RUN}"
    CLEAN_RUN = "${params.CLEAN_RUN}"
    DEBUG_RUN = "${params.DEBUG_RUN}"
    BRANCH_NAME = "${env.BRANCH_NAME}".replaceAll("feature/","")
    PROJECT_BRANCH = "${env.GIT_BRANCH}".replaceFirst("origin/","")
    BUILD_ID = "${env.BUILD_ID}"
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
      agent {
        label 'ansible-check&&ubuntu&&!albandri'
      }
      steps {
        script {
          properties(createPropertyList())
          setBuildName("Ansible project description.")
          if (! isReleaseBranch()) { abortPreviousRunningBuilds() }
        }
      }
    }
    stage("Ansible CMDB Report") {
      // Runs ansible-cmdb and publishes the report
      agent {
        label 'ansible-check&&ubuntu&&!albandri'
      }
      when {
        expression { BRANCH_NAME ==~ /(release|master|develop)/ }
      }
      steps {
        script {
          runAnsibleCmbd(shell: "./scripts/run-ansible-cmbd.sh")
        } // script
      }
    }
    stage('Documentation') {
      agent {
        label 'ansible-check&&ubuntu&&!albandri'
      }
      // Creates documentation using Sphinx and publishes it on Jenkins
      // Copy of the documentation is rsynced
      steps {
        script {
          runSphinx(shell: "./build.sh", targetDirectory: "fusionrisk-ansible/")
        }
      }
    }
    stage('SonarQube analysis') {
      agent {
        label 'ansible-check&&ubuntu&&!albandri'
      }
      environment {
        SONAR_SCANNER_OPTS = "-Xmx4g"
        SONAR_USER_HOME = "$WORKSPACE"
      }
      steps {
        script {
          withSonarQubeWrapper(verbose: true, skipMaven: true, repository: "ansible-nabla") {

          }
        }
      } // steps
    } // stage SonarQube analysis
    stage('Molecule - Java') {
      agent {
        label 'molecule'
      }
      steps {
        script {

          testAnsibleRole("ansiblebit.oracle-java")

        }
      }
    } // stage
    stage('Molecule') {
      //environment {
      //  MOLECULE_DEBUG="${params.MOLECULE_DEBUG ? '--debug' : ' '}"  // syntax: important to have the space ' '
      //}
      parallel {
        stage("administration") {
          agent {
            label 'molecule'
          }
          steps {
            script {
              testAnsibleRole("administration")
            }
          }
        }
        stage("common") {
          agent {
            label 'molecule'
          }
          steps {
            script {
              testAnsibleRole("common")
            }
          }
        }
        stage("security") {
          agent {
            label 'molecule'
          }
          steps {
            script {
              testAnsibleRole("security")
            }
          }
        }
      }
    }
    stage('Molecule parallel') {
      parallel {
        stage("cleaning") {
          agent {
            label 'molecule'
          }
          steps {
            script {
              testAnsibleRole("cleaning")
            }
          }
        }
        stage("DNS") {
          agent {
            label 'molecule'
          }
          steps {
            script {
              testAnsibleRole("dns")
            }
          }
        }
      }
    }
    stage('Docker') {
      parallel {
        stage('Ansible Self-Config') {
          agent {
            label 'docker-inside'
          }
          steps {
            script {
              println("TODO: test ansible role by self configuration of docker images")
            }
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            label 'docker-inside'
          }
          when {
            expression { BRANCH_NAME ==~ /(release-NO|master-NO|develop-NO)/ }
          }
          steps {
            script {
              if (! params.SKIP_DOCKER) {

                tee('docker-build-ubuntu-16.04.log') {

                  configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: '_')]) {

                    sh 'mkdir -p .ssh/ || true'

                    docker_build_args="--no-cache --pull --build-arg JENKINS_HOME=/home/jenkins --tag 1.0.4"

                    docker.withRegistry("${DOCKER_REGISTRY_URL}", "${DOCKER_REGISTRY_CREDENTIAL}") {
                       withCredentials([
                           [$class: 'UsernamePasswordMultiBinding',
                           credentialsId: DOCKER_REGISTRY_CREDENTIAL,
                           usernameVariable: 'USERNAME',
                           passwordVariable: 'PASSWORD']
                       ]) {
                         def container = docker.build("${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:1.0.4", "${docker_build_args} -f docker/ubuntu16/Dockerfile . ")
                         container.inside {
                           sh 'echo test'
                         }
                         docker.image("${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:1.0.4").withRun("-u root", "/bin/bash") {c ->

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
          agent {
            label 'docker-inside'
          }
          //when {
          //  expression { BRANCH_NAME ==~ /(release|master|develop)/ }
          //}
          steps {
            script {
              if (! params.SKIP_DOCKER) {

                tee('docker-build-ubuntu-18.04.log') {

                    try {

                      configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: '_')]) {

                        sh 'mkdir -p .ssh/ || true'

                        docker_build_args="--no-cache --pull --build-arg JENKINS_HOME=/home/jenkins --tag latest"

                        docker.withRegistry("${DOCKER_REGISTRY_URL}", "${DOCKER_REGISTRY_CREDENTIAL}") {
                           withCredentials([
                               [$class: 'UsernamePasswordMultiBinding',
                               credentialsId: DOCKER_REGISTRY_CREDENTIAL,
                               usernameVariable: 'USERNAME',
                               passwordVariable: 'PASSWORD']
                           ]) {
                            def container = docker.build("${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}", "${docker_build_args} -f docker/ubuntu18/Dockerfile . ")
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
                        } // withRegistry

                        echo "TODO JUNIT"

                        // TODO
                        //junit "target/jenkins-full-*.xml"

                      } // vault configFileProvider

                    } catch (e) {
                       echo 'Error: There were errors in tests. '+exc.toString()
                       currentBuild.result = 'UNSTABLE'
                       logs = "FAIL" // make sure other exceptions are recorded as failure too
                       error 'There are errors in tests'
                    } finally {
                       echo "finally"
                    } // finally


                    cst = sh (
                      script: "scripts/docker-test.sh || true",
                      returnStatus: true
                    )

                    echo "CONTAINER STRUCTURE TEST RETURN CODE : ${cst}"
                    if (cst == 0) {
                        echo "CONTAINER STRUCTURE TEST SUCCESS"
                        if (isReleaseBranch() && !DRY_RUN) {
                            echo "TODO : docker tag ${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT} ${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}"
                            echo "TODO : docker tag ${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT} ${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest"
                            echo "TODO : docker push ${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT}"
                            echo "TODO : docker push ${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest"
                        }
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
          agent {
            label 'docker-inside'
          }
          when {
            expression { BRANCH_NAME ==~ /(release|master|develop)/ }
          }
          steps {
            script {

              try {
                parallel "sample default maven project": {
                  def e2e = build job:'nabla-servers-bower-sample/master', propagate: false, wait: true
                  result = e2e.result
                  if (result.equals("SUCCESS")) {
                  } else {
                     sh "exit 1" // this fails the stage
                  }
                } // parallel
              } catch (e) {
                 currentBuild.result = 'UNSTABLE'
                 result = "FAIL" // make sure other exceptions are recorded as failure too
              }

            }
          }
        }
        stage("CentOS 7") {
          agent {
            label 'docker-inside'
          }
          steps {
            script {
              println("TODO: test centos 7 building")
            }
          }
        }
      }
    }
  }
  post {
    always {
      node('docker-inside') {

        runHtmlPublishers(["LogParserPublisher"])

        archiveArtifacts artifacts: "**/*.log, target/ansible-lint*", onlyIfSuccessful: false, allowEmptyArchive: true
      } // node

    }
    cleanup {
      wrapCleanWs()
    } // cleanup
  } // post
}
