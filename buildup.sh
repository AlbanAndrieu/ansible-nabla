#!/bin/bash

# VARIABLES
VAGRANT_HOME=/home/vagrant
ANSIBLE_PATH=$VAGRANT_HOME/.ansible

# basic config
#rm /etc/resolvconf/resolv.conf.d/base
#echo "nameserver 10.21.200.3" > /etc/resolvconf/resolv.conf.d/base
#echo "nameserver 10.25.200.3" >> /etc/resolvconf/resolv.conf.d/base
#sudo service resolvconf restart

# install prerequisites
apt-get update -qq
apt-get install make git-core git -y --force-yes

# Install some tools.
apt-get install vim-nox tmux sshpass -y --force-yes

# Install ansible prerequisites
apt-get install software-properties-common python-software-properties -y --force-yes
apt-add-repository ppa:ansible/ansible -y

# Install ansible dependencies
apt-get install python-mysqldb python-yaml python-jinja2 python-paramiko python-pycurl -y --force-yes

# Install ansible
apt-get update -qq
apt-get install ansible -y --force-yes

# Check if the Ansible repository exists.
if [[ ! -f /usr/bin/ansible ]]; then
  # Checkout the Ansible repository.
  su - vagrant -c 'git clone https://github.com/ansible/ansible.git $ANSIBLE_PATH'
  echo "source $ANSIBLE_PATH/hacking/env-setup" >> $VAGRANT_HOME/.bashrc
fi

# ssh config
echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# Get buildmasters repo
#env GIT_SSL_NO_VERIFY=true git clone --progress --branch feature/MGCE-1002 --depth 1 https://scm-git-eur.misys.global.ad/scm/risk/buildmasters.git $VAGRANT_HOME/buildmasters

# Authorize ansible master  
#cat $VAGRANT_HOME/buildmasters/Scripts/vagrant/keys/id_rsa.pub >> $VAGRANT_HOME/.ssh/authorized_keys
#cat $VAGRANT_HOME/buildmasters/Scripts/vagrant/keys/mgr.jenkins.pub >> $VAGRANT_HOME/.ssh/authorized_keys
#cp $VAGRANT_HOME/buildmasters/Scripts/vagrant/keys/id_rsa* $VAGRANT_HOME/.ssh

# making sure everything on $VAGRANT_HOME belongs to vagrant
chown -R vagrant:vagrant $VAGRANT_HOME

chmod 600 $VAGRANT_HOME/.ssh/authorized_keys
chmod 600 $VAGRANT_HOME/.ssh/id_rsa
chmod 600 $VAGRANT_HOME/.ssh/id_rsa.pub

# configure git for vagrant user
su - vagrant -c 'git config --global http.sslverify false && exit'

# Add jenkins users - TBD move to ansible
useradd jenkins
echo jenkins:microsoft | chpasswd
mkdir /jenkins
chown -R jenkins:jenkins /jenkins
  
echo "Done with buildup.sh"
