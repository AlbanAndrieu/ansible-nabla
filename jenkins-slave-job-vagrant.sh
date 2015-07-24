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

vagrant box list -i

VBoxManage list vms

# shutdown vms
VBoxManage controlvm hosttest0 poweroff || true
VBoxManage controlvm hosttest1 poweroff || true
VBoxManage controlvm hosttest2 poweroff || true

# delete vms
VBoxManage unregistervm hosttest0 -delete || true
VBoxManage unregistervm hosttest1 -delete || true
VBoxManage unregistervm hosttest2 -delete || true

#VBoxManage startvm vagrant-windows-2012 --type headless

# clean vagrant
vagrant destroy --force

# rebuild vagrant
vagrant up || exit 1
#vagrant up --debug || exit 1
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

echo "Check log at /home/jenkins/VirtualBox\ VMs/vagrant-windows-2012/Logs/VBox.log"
