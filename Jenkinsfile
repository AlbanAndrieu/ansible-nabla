node ('albandri'){
   stage('Preparation') { // for display purposes
      // Get some code from a Git repository
      checkout([$class: 'GitSCM', branches: [[name: '*/master']], browser: [$class: 'Stash', repoUrl: 'https://github.com/AlbanAndrieu/ansible-nabla'], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: true, timeout: 30]], gitTool: 'git-1.7.4.1', submoduleCfg: [], userRemoteConfigs: [[credentialsId: '8aaa3139-bdc4-4774-a08d-ee6b22a7e0ac', url: 'https://github.com/AlbanAndrieu/ansible-nabla.git']]])
   }
   stage('Build') {
        dir('Scripts/ansible') {
            sh 'ansible-galaxy install -r requirements.yml -p ./roles/ --ignore-errors'
            ansiblePlaybook colorized: true, extras: '-c local', installation: 'ansible-2.2.0.0', inventory: 'hosts', limit: 'albandri.misys.global.ad', playbook: 'docker.yml', sudoUser: null
        }
   }
   stage('Results') {
      //junit '**/target/surefire-reports/TEST-*.xml'
      archive 'target/*.jar'
   }
}
