#!/bin/bash
set -xv

echo "USER : $USER"
echo "HOME : $HOME"
echo "WORKSPACE : $WORKSPACE"

if [ -t 0 ]; then
   echo interactive
   stty erase ^H
else
   echo non-interactive
fi

#scl enable python27 bash
export PATH="/opt/rh/python27/root/usr/bin:/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
export LD_LIBRARY_PATH="/opt/rh/python27/root/usr/lib64"

#alias python='/opt/rh/python27/root/usr/bin/python2.7'

lsb_release -a

echo "Configure Jenkins slaves"

sudo apt-get update -qq
sudo apt-get install -qq python-apt python-pycurl
sudo apt-get install -qq wget
sudo apt-get install -qq virtualbox
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
sudo dpkg -i vagrant_1.6.3_x86_64.deb
#sudo pip install https://github.com/ansible/ansible/archive/devel.zip
sudo apt-get purge ansible
sudo pip uninstall ansible
sudo pip install ansible --upgrade
sudo pip install https://github.com/diyan/pywinrm/archive/df049454a9309280866e0156805ccda12d71c93a.zip --upgrade
#todo use virtualenv

sudo vagrant plugin install vagrant-vbguest
sudo vagrant plugin install vagrant-hosts vagrant-share vagrant-winrm
#vagrant plugin uninstall vagrant-windows
#vagrant plugin uninstall vagrant-lxc
sudo vagrant plugin list
#sudo vagrant plugin update

ansible --version
python --version
python2.7 --version

pip --version

vagrant --version
docker --version
VBoxManage --version

echo "###################"
echo "List VMS"
VBoxManage list vms
echo "List running VMS"
VBoxManage list runningvms



echo "###################"
vagrant status
#vagrant global-status
vagrant global-status --prune
vagrant box list -i

echo "###################"
#echo "Power off Jenkins slave"
#VBoxManage controlvm slave01 acpipowerbutton || true
#VBoxManage controlvm slave01 poweroff || true
#VBoxManage unregistervm slave01 --delete || true
#vagrant destroy slave01
#VBoxManage startvm slave01 --type headless || true

# shutdown vms
#VBoxManage controlvm host1 poweroff || true
#VBoxManage controlvm host2 poweroff || true

# delete vms
#VBoxManage unregistervm host1 -delete || true
#VBoxManage unregistervm host2 -delete || true

#VBoxManage startvm vagrant-windows-2012 --type headless

#echo "Delete master VM"
#VBoxManage controlvm master acpipowerbutton || true
#VBoxManage controlvm master poweroff || true
#VBoxManage unregistervm master --delete || true
vagrant destroy master

# clean vagrant
vagrant destroy --force

# rebuild vagrant
vagrant up || exit 1
#vagrant up --debug || exit 1

#vagrant provision

sshpass -f /jenkins/pass.txt ssh-copy-id vagrant@192.168.33.10
sshpass -f /jenkins/pass.txt ssh-copy-id vagrant@192.168.33.11
sshpass -f /jenkins/pass.txt ssh-copy-id vagrant@192.168.33.12

# test ansible

export ANSIBLE_REMOTE_USER=vagrant
export ANSIBLE_PRIVATE_KEY_FILE=$HOME/.vagrant.d/insecure_private_key
ssh-add $ANSIBLE_PRIVATE_KEY_FILE

#ansible -m setup slave01 -i hosts --user=vagrant --private-key=~/.vagrant.d/insecure_private_key  -vvvv
ansible -m setup slave01 -i hosts --user=vagrant -vvvv

ansible-playbook -i hosts jenkins-slave.yml --list-hosts
ansible-playbook -i hosts jenkins-slave.yml --limit=albandri-laptop-misys --list-tasks
ansible-playbook -i hosts jenkins-slave.yml -vvvv
#--extra-vars "jenkins_username=${JENKINS_USERNAME} jenkins_password=${JENKINS_PASSWORD}"
#ansible-playbook -i hosts jenkins-slave.yml -vvvv | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)

echo "Check log at /home/jenkins/VirtualBox\ VMs/vagrant-windows-2012/Logs/VBox.log"

echo "Connecting to master"
#vagrant ssh-config
ssh -p 2233 vagrant@10.21.22.69 "echo \"DONE\""

echo "Connecting to slave"
#vagrant ssh-config
ssh -p 2251 vagrant@10.21.22.69 "echo \"DONE\""
