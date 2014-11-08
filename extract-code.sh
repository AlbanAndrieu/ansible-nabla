#!/bin/sh

#create a git local repo
#touch README.md
#git init
#git add README.md
#git commit -m "first commit"
#git remote add origin https://github.com/AlbanAndrieu/ansible-swarm.git
#git push -u origin master

git clone https://github.com/AlbanAndrieu/ansible-nabla.git ansible

git submodule add https://github.com/AlbanAndrieu/ansigenome.git 

mkdir roles

cd roles

#git submodule add https://github.com/AlbanAndrieu/devbox.chrome.git chrome
#...


#git clone https://github.com/debops/ansible-role-ansible.git ansible
git submodule add https://github.com/debops/ansible-role-ansible.git ansible

#git clone https://github.com/EDITD/ansible-supervisor_task.git supervisor
git submodule add https://github.com/AlbanAndrieu/ansible-supervisor_task.git supervisor
#pull request pending

git submodule add https://github.com/AlbanAndrieu/ansible-webmin.git webmin

git submodule add https://github.com/AlbanAndrieu/ansible-xvbf.git xvbf

git submodule add https://github.com/AlbanAndrieu/ansible-zfs.git zfs

#git clone https://github.com/ahelal/ansible-zabbix_agent zabbix_agent
git submodule add https://github.com/AlbanAndrieu/ansible-zabbix_agent.git zabbix-agent

#git clone https://github.com/ahelal/ansible-zabbix_server zabbix-server
git submodule add https://github.com/AlbanAndrieu/ansible-zabbix_server.git zabbix-server

git submodule add https://github.com/knopki/ansible-locale locale

#git clone https://github.com/kost/ansible-galaxy.ubuntu.virtualbox.git virtualbox
git submodule add https://github.com/AlbanAndrieu/ansible-galaxy.ubuntu.virtualbox.git virtualbox

#git clone https://github.com/aw/ansible-galaxy-vagrant.git vagrant-user
#git submodule add https://github.com/AlbanAndrieu/ansible-galaxy-vagrant.git vagrant-user

#git clone https://github.com/klynch/ansible-vagrant-role.git vagrant
#TODO switch
git submodule add https://github.com/AlbanAndrieu/ansible-vagrant-role.git vagrant

#TODO control vagrant with ansible https://github.com/robparrott/ansible-vagrant

#git clone https://github.com/angstwad/docker.ubuntu.git docker
git submodule add https://github.com/AlbanAndrieu/docker.ubuntu.git docker

#git clone https://github.com/silpion/ansible-maven maven
git submodule add https://github.com/AlbanAndrieu/ansible-maven.git maven

#git clone https://github.com/silpion/ansible-java java
git submodule add https://github.com/AlbanAndrieu/ansible-java.git java
#pull request pending

#git clone https://github.com/alourie/devbox.chrome.git chrome
git submodule add https://github.com/AlbanAndrieu/devbox.chrome.git chrome

#git clone https://github.com/Stouts/Stouts.jenkins.git jenkins-master
git submodule add https://github.com/AlbanAndrieu/Stouts.jenkins.git jenkins-master
#pull request pending

git submodule add https://github.com/AlbanAndrieu/ansible-jenkins-slave.git jenkins-slave

git submodule add https://github.com/AlbanAndrieu/ansible-jenkins-swarm.git jenkins-swarm

git submodule add https://github.com/AlbanAndrieu/ansible-dropbox.git dropbox

#git clone https://github.com/ahelal/ansible-sonar.git sonar
git submodule add https://github.com/AlbanAndrieu/ansible-sonar.git sonar
#pull request mysql

git submodule add https://github.com/AlbanAndrieu/ansible-selenium.git selenium

git submodule add https://github.com/AlbanAndrieu/ansible-nodejs.git nodejs

git submodule add https://github.com/AlbanAndrieu/ansible-conky.git conky

git submodule add https://github.com/AlbanAndrieu/ansible-subversion.git subversion

git submodule add https://github.com/AlbanAndrieu/ansible-css.git css

#http://www.funix.org/fr/linux/intrusions.htm
#git clone https://github.com/geerlingguy/ansible-role-security.git security
git submodule add https://github.com/AlbanAndrieu/ansible-role-security.git security
#TODO pull request

git submodule add https://github.com/AlbanAndrieu/ansible-zap.git zap

#git clone https://github.com/ahelal/ansible-sonatype_nexus.git nexus
git submodule add https://github.com/AlbanAndrieu/ansible-sonatype_nexus.git nexus

git submodule add https://github.com/AlbanAndrieu/ansible-cmake.git cmake

git submodule add https://github.com/AlbanAndrieu/ansible-shell.git shell

git submodule add https://github.com/AlbanAndrieu/ansible-eclipse.git eclipse

git submodule add https://github.com/AlbanAndrieu/ansible-jboss.git jboss

git submodule add https://github.com/AlbanAndrieu/ansible-windows.git windows

git submodule add https://github.com/AlbanAndrieu/ansible-cpp.git cpp

git submodule add https://github.com/AlbanAndrieu/ansible-pagespeed.git pagespeed

git submodule add https://github.com/AlbanAndrieu/ansible-jmeter.git jmeter

git submodule add https://github.com/AlbanAndrieu/ansible-mon.git mon

git submodule add https://github.com/AlbanAndrieu/ansible-grive.git grive

git submodule add https://github.com/Stouts/Stouts.python.git python

git submodule add https://github.com/AlbanAndrieu/ansible-web.git web

git submodule add https://github.com/AlbanAndrieu/ansible-common.git common

git submodule add https://github.com/AlbanAndrieu/ansible-administration.git administration

git submodule add https://github.com/AlbanAndrieu/ansible-workstation.git workstation

git submodule add https://github.com/AlbanAndrieu/ansible-dns.git dns

git submodule add https://github.com/AlbanAndrieu/ansible-tomcat.git tomcat

git submodule add https://github.com/AlbanAndrieu/ansible-hostname.git hostname

#git clone https://github.com/debops/ansible-monit.git monit
git submodule add https://github.com/ANXS/monit monit

#LAMP
git submodule add https://github.com/geerlingguy/ansible-role-firewall.git geerlingguy.firewall
git submodule add https://github.com/geerlingguy/ansible-role-ntp.git geerlingguy.ntp
git submodule add https://github.com/geerlingguy/ansible-role-repo-epel.git geerlingguy.repo-epel
git submodule add https://github.com/geerlingguy/ansible-role-repo-remi.git geerlingguy.repo-remi
git submodule add https://github.com/geerlingguy/ansible-role-apache.git geerlingguy.apache
#see fork below git clone https://github.com/geerlingguy/ansible-role-mysql.git mysql
#see fork of fork below git clone https://github.com/augustohp/ansible-role-mysql.git mysql
git submodule add https://github.com/AlbanAndrieu/ansible-role-mysql.git geerlingguy.mysql
git submodule add https://github.com/geerlingguy/ansible-role-php.git geerlingguy.php
git submodule add https://github.com/geerlingguy/ansible-role-php-mysql.git geerlingguy.php-mysql
git submodule add https://github.com/geerlingguy/ansible-role-phpmyadmin.git geerlingguy.phpmyadmin
#TODO git clone https://github.com/geerlingguy/ansible-role-varnish.git varnish
git submodule add https://github.com/geerlingguy/ansible-role-samba.git geerlingguy.samba

#git clone https://github.com/valentinogagliardi/logstash-role.git logstash
#TODO merge below geerlingguy.java with other java role
git submodule add https://github.com/geerlingguy/ansible-role-java geerlingguy.java
git submodule add https://github.com/geerlingguy/ansible-role-elasticsearch.git geerlingguy.elasticsearch
#git clone https://github.com/geerlingguy/ansible-role-logstash geerlingguy.logstash
git submodule add https://github.com/AlbanAndrieu/ansible-role-logstash.git geerlingguy.logstash

git submodule add https://github.com/geerlingguy/ansible-role-nginx.git geerlingguy.nginx
#git clone https://github.com/geerlingguy/ansible-role-kibana.git geerlingguy.kibana
git submodule add https://github.com/AlbanAndrieu/ansible-role-kibana.git geerlingguy.kibana

#SEE
#https://github.com/ansible/ansible-examples/tree/master/language_features
#https://github.com/sheldonh/dotfiles-ansible
#https://github.com/ginas/ginas
#SEE and check
#git submodule add https://github.com/major/ansible-role-cis.git security-cis

#TODO
#https://github.com/weareinteractive/ansible-users-git
#https://github.com/goozbach-ansible/role-jenkins-git/blob/master/tasks/main.yml get plugins in jenkins

#https://github.com/debops/ansible-tcpwrappers

#https://github.com/wouterd/docker-maven-plugin
#https://github.com/Ansibles/monit
#https://github.com/sheldonh/dotfiles-ansible #bog
#https://github.com/sivel/ansible-newrelic
#https://github.com/fretscha-ansible/ansible-role-first-five-minutes
#https://github.com/bennojoy/memcached
#https://github.com/nickjj/ansible-security #for firewall

#https://github.com/AnsibleShipyard/ansible-nodejs
#https://github.com/Stouts/Stouts.backup

#Below it can be usefull for maintenance purpose
#https://github.com/mivok/ansible-users

ansigenome gendoc -f md
