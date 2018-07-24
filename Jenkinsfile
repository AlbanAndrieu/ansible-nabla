#!/usr/bin/env groovy
/*
    Point of this Jenkinsfile is to:
    - define global behavior
*/

def isReleaseBranch() {
    env.BRANCH_NAME ==~ /develop/ || env.BRANCH_NAME ==~ /master/ || env.BRANCH_NAME ==~ /release\/.*/
}

def abortPreviousRunningBuilds() {
  def hi = Hudson.instance
  def pname = env.JOB_NAME.split('/')[0]

  try {
    hi.getItem(pname).getItem(env.JOB_BASE_NAME).getBuilds().each{ build ->
    def exec = build.getExecutor()

    if (build.number != currentBuild.number && exec != null) {
      exec.interrupt(
        Result.ABORTED,
        new CauseOfInterruption.UserInterruption(
          "Aborted by #${currentBuild.number}"
        )
      )
      println("Aborted previous running build #${build.number} - ${env.JOB_BASE_NAME}")
    } else {
      println("Build ${pname} / ${env.JOB_BASE_NAME} is not running or is already built, not aborting #${build.number}")
    }
  }
  } catch(NullPointerException e) {
      // happens the first time if there is no branch at all
  } finally {
      // carry on as if nothing went wrong
  }

} // abortPreviousRunningBuilds

def daysToKeep         = isReleaseBranch() ? '30' : '10'
def numToKeep          = isReleaseBranch() ? '20' : '5'
def artifactDaysToKeep = isReleaseBranch() ? '30' : '10'
def artifactNumToKeep  = isReleaseBranch() ? '3'  : '1'
def cronString         = isReleaseBranch() ? 'H H(3-7) * * 1-5' : ''

def DOCKERREGISTRY="docker.hub"
//def DOCKERORGANISATION="nabla"
def DOCKERTAG="latest"
def DOCKERUSERNAME="nabla"
def DOCKERNAME="ansible-jenkins-slave"

def DOCKER_REGISTRY_URL = "https://${DOCKERREGISTRY}"
def DOCKER_REGISTRY_CREDENTIAL = 'nabla'
def DOCKER_IMAGE = "${DOCKERUSERNAME}/${DOCKERNAME}:${DOCKERTAG}"

//JENKINS-42369 : Docker options need to be defined outside of pipeline
def DOCKER_OPTS = [
    '--net=host',
    '--pid=host',
//    '--dns-search=nabla.mobi',
//    '-v /home/jenkins/.m2:/home/jenkins/.m2 ',
    '-v /home/jenkins:/home/jenkins',
    '-v /etc/passwd:/etc/passwd:ro ',
    '-v /etc/group:/etc/group:ro '
].join(" ")

/*
    Point of this Jenkinsfile is to:
    - build java project
*/
pipeline {
    agent {
      label 'ansible-check&&ubuntu&&!albandri
    }
    triggers {
        cron(cronString)
        //pollSCM '@hourly'
        bitbucketPush()
    }
    parameters {
        //booleanParam(name: "RELEASE", defaultValue: false, description: "Perform release-type build.")
        string(defaultValue: 'develop', description: 'Default git branch to override', name: 'GIT_BRANCH_NAME')
        string(defaultValue: '--check', description: 'Default mode used to test playbook', name: 'DRY_RUN')
        string(defaultValue: '', description: 'Default inventory used to test playbook', name: 'DOCKER_RUN')
        string(defaultValue: 'production', description: 'Default inventory used to test playbook', name: 'ANSIBLE_INVENTORY')
        string(defaultValue: 'albandri', description: 'Default server used to test playbook', name: 'TARGET_SLAVE')
        string(defaultValue: 'jenkins-slave.yml', description: 'Default playbook to override', name: 'TARGET_PLAYBOOK')
        string(defaultValue: '/usr/bin/python3.5', description: 'Default python command to override', name: 'PYTHON_CMD')
        string(defaultValue: 'LATEST_SUCCESSFULL', description: 'Create a TAG', name: 'TARGET_TAG')
        //string(defaultValue: '', description: 'Shall we build docker image', name: 'DOCKER_RUN')
        string(defaultValue: 'jenkins', description: 'User', name: 'TARGET_USER')
        //booleanParam(defaultValue: false, description: 'Dry run', name: 'DRY_RUN')
        booleanParam(defaultValue: false, description: 'Clean before run', name: 'CLEAN_RUN')
        //booleanParam(defaultValue: false, description: 'Debug run', name: 'DEBUG_RUN')
    }
    environment {
        JENKINS_CREDENTIALS = 'jenkins-ssh'
        GIT_BRANCH_NAME = "${params.GIT_BRANCH_NAME}"
        //CARGO_RMI_PORT = "${params.CARGO_RMI_PORT}"
       // WORKSPACE_SUFFIX = "${params.WORKSPACE_SUFFIX}"
        DRY_RUN = "${params.DRY_RUN}"
        CLEAN_RUN = "${params.CLEAN_RUN}"
        DEBUG_RUN = "${params.DEBUG_RUN}"
        //echo "JOB_NAME: ${env.JOB_NAME} : ${env.JOB_BASE_NAME}"
        TARGET_PROJECT = sh(returnStdout: true, script: "echo ${env.JOB_NAME} | cut -d'/' -f -1").trim()
        BRANCH_NAME = "${env.BRANCH_NAME}".replaceAll("feature/","")
        PROJECT_BRANCH = "${env.GIT_BRANCH}".replaceFirst("origin/","")
        BUILD_ID = "${env.BUILD_ID}"
        SONAR_BRANCH = sh(returnStdout: true, script: "echo ${env.BRANCH_NAME} | cut -d'/' -f 2-").trim()
        GIT_AUTHOR_EMAIL = "${env.CHANGE_AUTHOR_EMAIL}"
        GIT_PROJECT = "ansible-nabla"
        GIT_BROWSE_URL = "https://github.com/AlbanAndrieu/${GIT_PROJECT}/"
        //GIT_URL = "https://github.com/scm/AlbanAndrieu/${GIT_PROJECT}.git"
        GIT_URL = "ssh://git@github.com/AlbanAndrieu/${GIT_PROJECT}.git"
        GIT_COMMIT = "TODO"
    }
    options {
        //disableConcurrentBuilds()
        timeout(time: 360, unit: 'MINUTES')
        buildDiscarder(
          logRotator(
            daysToKeepStr: daysToKeep,
            numToKeepStr: numToKeep,
            artifactDaysToKeepStr: artifactDaysToKeep,
            artifactNumToKeepStr: artifactNumToKeep
          )
        )
    }
    stages {
        stage('Cleaning') {
            steps {
                script {
                    //utils = load "Jenkinsfile-vars"
                    if (! isReleaseBranch()) { abortPreviousRunningBuilds() }
                }
            }
        }
        stage('Preparation') { // for display purposes
            steps {
                checkout scm
                script {
                    //properties(utils.createPropertyList())
                    sh "git rev-parse --short HEAD > .git/commit-id"
                    GIT_COMMIT = readFile('.git/commit-id')
                }

                echo "GIT_COMMIT: ${GIT_COMMIT}"
                echo "SONAR_BRANCH: ${SONAR_BRANCH}"
                echo "PROJECT_BRANCH: ${PROJECT_BRANCH}"
                echo "BRANCH_NAME: ${env.BRANCH_NAME}"
                echo "GIT_BRANCH_NAME: ${env.GIT_BRANCH_NAME}"

                //checkout([
                //    $class: 'GitSCM',
                //    branches: [[name: "${env.GIT_BRANCH_NAME}"]],
                //    browser: [
                //        $class: 'Stash',
                //        repoUrl: "${env.GIT_BROWSE_URL}"],
                //    doGenerateSubmoduleConfigurations: false,
                //    extensions: [
                //        [$class: 'CloneOption', depth: 0, noTags: true, reference: '', shallow: true],
                //        [$class: 'LocalBranch', localBranch: "${env.GIT_BRANCH_NAME}"],
                //        [$class: 'RelativeTargetDirectory', relativeTargetDir: 'bm'],
                //        [$class: 'MessageExclusion', excludedMessage: '.*\\\\[maven-release-plugin\\\\].*'],
                //        [$class: 'IgnoreNotifyCommit'],
                //        [$class: 'ChangelogToBranch', options: [compareRemote: 'origin', compareTarget: 'release/1.0.0']]
                //    ],
                //    gitTool: 'git-latest',
                //    submoduleCfg: [],
                //    userRemoteConfigs: [[
                //        credentialsId: "${env.JENKINS_CREDENTIALS}",
                //        url: "${env.GIT_URL}"]
                //    ]
                //])

                sh 'ansible-galaxy install -r requirements.yml -p ./roles/ --ignore-errors'
            }
        }
        stage('Build') { // for display purposes
            steps {
                // check syntax
                ansiblePlaybook colorized: true, extras: '-vvvv --syntax-check', installation: 'ansible-2.2.0.0', inventory: 'production', limit: 'FR1CSLFRBM0059.misys.global.ad', playbook: 'jenkins-slave.yml', sudoUser: null

                script {
                // check quality
                    sh returnStatus: true, script: 'ansible-lint jenkins-slave.yml || true'

                    sh './run-ansible-workstation.sh'
            }
        }
        }
        stage('Docker') {
            when {
                expression { BRANCH_NAME ==~ /(release|master|develop)/ }
            }
           steps {
               script {
                    docker_build_args="--no-cache --pull --build-arg JENKINS_HOME=/home/jenkins"
                   //-f Dockerfile-jenkins-slave-ubuntu:16.04 . --no-cache  -t "${DOCKERUSERNAME}/${DOCKERNAME}" --tag "${DOCKERTAG}"

                   docker.withRegistry("${DOCKER_REGISTRY_URL}", "${DOCKER_REGISTRY_CREDENTIAL}") {
                       withCredentials([
                           [$class: 'UsernamePasswordMultiBinding',
                           credentialsId: DOCKER_REGISTRY_CREDENTIAL,
                           usernameVariable: 'USERNAME',
                           passwordVariable: 'PASSWORD']
                       ]) {
                           //sh "docker login --password=${PASSWORD} --username=${USERNAME} ${DOCKER_REGISTRY_URL}"
                           //git '…'
                           def container = docker.build("${DOCKER_IMAGE}", "${docker_build_args} -f Dockerfile-jenkins-slave-ubuntu:16.04 . ")
                           container.inside {
                             sh 'echo test'
                           }
                           //container.push()  // record this snapshot (optional)
                           //stage 'Test image'
                           stage('Test image') {
                               //docker run -i -t --entrypoint /bin/bash ${myImg.imageName()}
                               docker.image(${DOCKER_IMAGE}).withRun {c ->
                               sh "docker logs ${c.id}"
                               }
                           }
                           // run some tests on it (see below), then if everything looks good:
                           //stage 'Approve image'
                           //container.push 'test'
                           //def myImg = docker.image(${DOCKER_IMAGE})
                           //sh "docker push ${myImg.imageName()}"
                       } // withCredentials
                   }
               } //script
           }
        }

        stage('SonarQube analysis') {
            environment {
                SONAR_SCANNER_OPTS = "-Xmx1g"
            }
            steps {
                script {
                    sh "pwd"
                    sh "/usr/local/sonar-runner/bin/sonar-scanner -D sonar-project.properties"
                }
            }
        }
        //stage('Approve image') {
        // sshagent(['19d51c37-1c1f-4c73-8282-08abea3f0b87']) {
        ////   def myImg = docker.image("${DOCKER_IMAGE}")
        ////   sh "docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz ${myImg.imageName()}"
         //    sh returnStdout: true, script: 'sudo docker run -it --net host --pid host --cap-add audit_control -v /var/lib:/var/lib -v /var/run/docker.sock:/var/run/docker.sock -v /usr/lib/systemd:/usr/lib/systemd -v /etc:/etc --label docker_bench_security docker/docker-bench-security'
         //}
        //}
    } //stages
} // pipeline
