#!/usr/bin/env groovy
@Library('nabla-pipeline-scripts') _

/*
 * Fusion Risk Ansible
 *
 * Test Ansible Playbooks by: ansible-lint, ansible-playbook on docker images
 */

def DOCKER_REGISTRY="docker.hub"
def DOCKER_TAG="latest"
def DOCKER_NAME="ansible-jenkins-slave"
def DOCKERUSERNAME="nabla"

def DOCKER_REGISTRY_URL="https://${DOCKER_REGISTRY}"
def DOCKER_REGISTRY_CREDENTIAL='jenkins'
def DOCKER_IMAGE="${DOCKER_REGISTRY}/${DOCKERUSERNAME}/${DOCKER_NAME}:1.0.1"

def DOCKER_OPTS = [
  '--dns-search=nabla.mobi',
  '-v /etc/passwd:/etc/passwd:ro ',
  '-v /etc/group:/etc/group:ro '
].join(" ")

pipeline {
  agent {
    label 'ansible-check'
  }
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
    DRY_RUN = "${params.DRY_RUN}"
    CLEAN_RUN = "${params.CLEAN_RUN}"
    DEBUG_RUN = "${params.DEBUG_RUN}"
    BRANCH_NAME = "${env.BRANCH_NAME}".replaceAll("feature/","")
    PROJECT_BRANCH = "${env.GIT_BRANCH}".replaceFirst("origin/","")
    BUILD_ID = "${env.BUILD_ID}"
  }
  options {
    disableConcurrentBuilds()
    ansiColor('xterm')
    timeout(time: 360, unit: 'MINUTES')
    timestamps()
  }
  stages {
    stage('Setup') {
      steps {
        script {
          properties(createPropertyList())
          setBuildName()
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
          configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: '_')]) {
            sh "./run-ansible-cmbd.sh"
          }
          publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: "./overwiev/",
            reportFiles: 'overview.html',
            includes: '**/*',
            reportName: 'Ansible CMDB Report',
            reportTitles: "Ansible CMDB Report Index"
          ])

          junit "target/ansible-lint.xml"

        }
      }
    }
    stage('Documentation') {
      // Creates documentation using Sphinx and publishes it on Jenkins
      // Copy of the documentation is rsynced with kgrdb01
      steps {
        script {
          dir("docs") {
            sh "source /opt/ansible/env35/bin/activate && make html"
          }
          publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: "./docs/_build/html/",
            reportFiles: 'index.html',
            includes: '**/*',
            reportName: 'Sphinx Docs',
            reportTitles: "Sphinx Docs Index"
          ])
          if (isReleaseBranch()) {
            // Initially, we will want to publish only one version,
            // i.e. the latest one from develop branch.
            dir("docs/_build/html") {
              rsync([
                source: "*",
                destination: "jenkins@albandri:/kgr/release/docs/fusionrisk-ansible/",
                credentialsId: "jenkins_unix_slaves"
              ])
            }
          }
        }
      }
    }
    stage('SonarQube analysis') {
      environment {
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
            expression { BRANCH_NAME ==~ /(release|master|develop)/ }
          }
          steps {
            script {
              if (! params.SKIP_DOCKER) {

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
                       def container = docker.build("${DOCKER_IMAGE}", "${docker_build_args} -f docker/ubuntu16/Dockerfile . ")
                       container.inside {
                         sh 'echo test'
                       }
                       docker.image("${DOCKER_IMAGE}").withRun("-u root", "/bin/bash") {c ->
                         sh "docker logs ${c.id}"
                       }
                     }
                  }
                } // vault
              }
            }
          }
        }
        stage('Ubuntu 18.04') {
          agent {
            label 'docker-inside'
          }
          when {
            expression { BRANCH_NAME ==~ /(release|master|develop)/ }
          }
          steps {
            script {
              if (! params.SKIP_DOCKER) {

                configFileProvider([configFile(fileId: 'vault.passwd',  targetLocation: 'vault.passwd', variable: '_')]) {

                  sh 'mkdir -p .ssh/ || true'

                  docker_build_args="--no-cache --pull --build-arg JENKINS_HOME=/home/jenkins --tag 1.0.8"

                  docker.withRegistry("${DOCKER_REGISTRY_URL}", "${DOCKER_REGISTRY_CREDENTIAL}") {
                     withCredentials([
                         [$class: 'UsernamePasswordMultiBinding',
                         credentialsId: DOCKER_REGISTRY_CREDENTIAL,
                         usernameVariable: 'USERNAME',
                         passwordVariable: 'PASSWORD']
                     ]) {
                      def container = docker.build("${DOCKER_IMAGE}", "${docker_build_args} -f docker/ubuntu18/Dockerfile . ")
                      container.inside {
                        sh 'echo test'
                      }

                      //docker run -i -t --entrypoint /bin/bash ${myImg.imageName()}
                      docker.image("${DOCKER_IMAGE}").withRun("-u root", "/bin/bash") {c ->
                        sh "docker logs ${c.id}"
                      }

                      parallel "sample default maven project": {
                        build_test = build(job:"TEST/nabla-servers-bower-sample/develop",
                        wait: true,
                        propagate: false).result
                        if (build_test == 'FAILURE') {
                            echo "First job failed"
                            currentBuild.result = 'UNSTABLE' // of FAILURE
                        }
                      } // parallel
                    }
                  }

                  // TODO
                  //junit "target/jenkins-full-*.xml"

                } // vault
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
      archiveArtifacts artifacts: "**/*.log", onlyIfSuccessful: false, allowEmptyArchive: true
      runHtmlPublishers(["LogParserPublisher", "AnalysisPublisher"])
    }
    success {
      script {
        if (! isReleaseBranch()) { cleanWs() }
      }
    }
  } // post
}
