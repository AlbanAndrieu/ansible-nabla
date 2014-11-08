#!/bin/bash
set -xv
echo "USER : $USER"
echo "HOME : $HOME"
echo "WORKSPACE : $WORKSPACE"

echo "Configure Jenkins slaves"

sudo apt-get update -qq
sudo apt-get install -qq python-apt python-pycurl
sudo apt-get install -qq wget
sudo apt-get install -qq virtualbox
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
sudo dpkg -i vagrant_1.6.3_x86_64.deb
sudo pip install https://github.com/ansible/ansible/archive/devel.zip
sudo pip install https://github.com/diyan/pywinrm/archive/df049454a9309280866e0156805ccda12d71c93a.zip --upgrade
#todo use virtualenv

ansible --version
vagrant --version
docker --version
python --version
pip --version
VBoxManage --version

cd ./Scripts/ansible

vagrant box list

# shutdown vms
VBoxManage controlvm hosttest0 poweroff
VBoxManage controlvm hosttest1 poweroff
VBoxManage controlvm hosttest2 poweroff

# delete vms
VBoxManage unregistervm hosttest0 -delete
VBoxManage unregistervm hosttest1 -delete
VBoxManage unregistervm hosttest2 -delete

# clean vagrant
vagrant destroy --force

# rebuild vagrant
vagrant up
vagrant provision
vagrant status

sshpass -f /jenkins/pass.txt ssh-copy-id vagrant@192.168.33.10
sshpass -f /jenkins/pass.txt ssh-copy-id vagrant@192.168.33.11
sshpass -f /jenkins/pass.txt ssh-copy-id vagrant@192.168.33.12

# test ansible
ansible-playbook -i hosts jenkins-slave.yml --list-hosts
ansible-playbook -i hosts jenkins-slave.yml --limit=albandri-laptop-misys --list-tasks
ansible-playbook -i hosts jenkins-slave.yml -vvvv
#--extra-vars "jenkins_username=${JENKINS_USERNAME} jenkins_password=${JENKINS_PASSWORD}"
#ansible-playbook -i hosts jenkins-slave.yml -vvvv | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
