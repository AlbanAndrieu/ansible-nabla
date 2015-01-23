#!/bin/bash
set -xv

echo "USER : $USER"
echo "HOME : $HOME"
echo "WORKSPACE : $WORKSPACE"

lsb_release -a

echo "Configure Jenkins slaves"

sudo apt-get update -qq
sudo apt-get install -qq python-apt python-pycurl
sudo apt-get install -qq wget
#sudo apt-get install -qq virtualbox
#wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
#sudo dpkg -i vagrant_1.6.3_x86_64.deb
#sudo pip install https://github.com/ansible/ansible/archive/devel.zip
sudo apt-get purge -y ansible
#/usr/bin/yes | sudo pip uninstall ansible
sudo pip install ansible --upgrade
sudo pip install https://github.com/diyan/pywinrm/archive/df049454a9309280866e0156805ccda12d71c93a.zip --upgrade
#todo use virtualenv

ansible --version
python --version
pip --version

#vagrant --version
#docker --version

git pull origin master && git submodule init && git submodule update && git submodule status || exit 1
git submodule foreach git checkout master || exit 2

#List hosts
ansible-playbook -i hosts -v nabla.yml --list-hosts || exit 3

#List tasks
ansible-playbook -i hosts -v nabla.yml --limit=localhost --list-tasks || exit 4

#Check syntax 
sudo ansible-playbook -i hosts -c local -v nabla.yml -vvvv --syntax-check || exit 5

#Run ansible
sudo ansible-playbook -i hosts -c local -v nabla.yml -vvvv || exit 6
#./setup.sh
#ansible-playbook -i hosts-c local -v nabla.yml -vvvv
#--extra-vars "jenkins_username=${JENKINS_USERNAME} jenkins_password=${JENKINS_PASSWORD}"
#ansible-playbook -i hosts jenkins-slave.yml -vvvv | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
