#!/usr/bin/env groovy
@Library('nabla-pipeline-scripts') _

/*
 * Fusion Risk Ansible
 *
 * Test Ansible Playbooks by: ansible-lint, ansible-playbook on docker images
 */

String DOCKER_REGISTRY="docker.hub".trim()
String DOCKER_ORGANISATION="nabla".trim()
String DOCKER_TAG="1.0.1".trim()
String DOCKER_TAG_NEXT="1.0.2".trim()
String DOCKER_NAME="ansible-jenkins-slave".trim()

String DOCKER_REGISTRY_URL="https://${DOCKER_REGISTRY}".trim()
String DOCKER_REGISTRY_CREDENTIAL=env.DOCKER_REGISTRY_CREDENTIAL ?: "jenkins".trim()
String DOCKER_IMAGE="${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}".trim()

String DOCKER_OPTS_BASIC = getDockerOpts()
String DOCKER_OPTS_COMPOSE = getDockerOpts(isDockerCompose: true, isLocalJenkinsUser: false)

pipeline {
  //agent none
  agent {
    label 'molecule'
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
  }
  environment {
    ANSIBLE_VAULT_PASS = "${params.ANSIBLE_VAULT_PASS}".trim()
    DRY_RUN = "${params.DRY_RUN}".toBoolean()
    CLEAN_RUN = "${params.CLEAN_RUN}".toBoolean()
    DEBUG_RUN = "${params.DEBUG_RUN}".toBoolean()
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
        docker {
          image DOCKER_IMAGE
          alwaysPull true
          reuseNode true
          args DOCKER_OPTS_COMPOSE
          label 'molecule'
        }
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
        label 'molecule'
      }
      steps {
        script {
          runAnsibleCmbd(shell: "./scripts/run-ansible-cmbd.sh")
        } // script
      }
    }
    stage('Documentation') {
      agent {
        docker {
          image DOCKER_IMAGE
          alwaysPull true
          reuseNode true
          args DOCKER_OPTS_COMPOSE
          label 'molecule'
        }
      }
      // Creates documentation using Sphinx and publishes it on Jenkins
      // Copy of the documentation is rsynced
      steps {
        script {
          runSphinx(shell: "./build.sh", targetDirectory: "fusionrisk-ansible/")
        }
      }
    }

    stage('Cleaning tests') {
      agent {
        label 'molecule'
      }
      steps {
        script {
          configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: '_')]) {
            ansiblePlaybook colorized: true,
                credentialsId: 'jenkins_unix_slaves',
                disableHostKeyChecking: true,
                extras: '-e ansible_python_interpreter="/usr/bin/python2.7"',
                forks: 5,
                installation: 'ansible-latest',
                inventory: "${ANSIBLE_INVENTORY}",
                limit: "${TARGET_SLAVE}",
                playbook: "${TARGET_PLAYBOOK}"
          } // configFileProvider
        } // script
      } // steps
    } // stage SonarQube analysis

    stage('SonarQube analysis') {
      agent {
        label 'molecule'
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
            label 'molecule'
          }
          steps {
            script {
              println("TODO: test ansible role by self configuration of docker images")
            }
          }
        }
        stage('Ubuntu 16.04') {
          agent {
            label 'molecule'
          }
          when {
            expression { BRANCH_NAME ==~ /(release|master|develop-NO)/ }
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
          agent {
            label 'molecule'
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

                        docker_build_args="--no-cache --pull --build-arg JENKINS_HOME=/home/jenkins --tag ${DOCKER_TAG_NEXT}"

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

                    } catch (exc) {
                       echo 'Error: There were errors in tests. '+exc.toString()
                       currentBuild.result = 'UNSTABLE'
                       logs = "FAIL" // make sure other exceptions are recorded as failure too
                       error 'There are errors in tests'
                    } finally {
                       echo "finally"
                    } // finally

                    cst = sh (
                      script: "scripts/docker-test.sh ${DOCKER_NAME} ${DOCKER_TAG_NEXT}",
                      returnStatus: true
                    )

                    echo "CONTAINER STRUCTURE TEST RETURN CODE : ${cst}"
                    if (cst == 0) {
                        echo "CONTAINER STRUCTURE TEST SUCCESS"
                        if (isReleaseBranch() && !DRY_RUN) {
                            echo "TODO : docker tag ${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG_NEXT} ${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:1.0.20"
                            echo "TODO : docker push ${DOCKER_REGISTRY}/${DOCKER_ORGANISATION}/${DOCKER_NAME}:1.0.20"
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
            label 'molecule'
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
      }
    }
  }
  post {
    always {
      node('molecule') {

        runHtmlPublishers(["LogParserPublisher"])

        archiveArtifacts artifacts: "**/*.log, target/ansible-lint*", onlyIfSuccessful: false, allowEmptyArchive: true
      } // node

    }
    //cleanup {
    //  wrapCleanWsOnNode()
    //} // cleanup
  } // post
}
