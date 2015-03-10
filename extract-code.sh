#!/bin/sh

#create a git local repo
#touch README.md
#git init
#git add README.md
#git commit -m "first commit"
#git remote add origin https://github.com/AlbanAndrieu/ansible-swarm.git
#git push -u origin master

git clone https://github.com/AlbanAndrieu/ansible-nabla.git ansible

git pull && git submodule init && git submodule update && git submodule status
#git fetch --recurse-submodules
#git submodule foreach git fetch
git submodule foreach git pull origin master
git submodule foreach git checkout master

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

#git submodule deinit -f webmin
git submodule add https://github.com/AlbanAndrieu/ansible-webmin.git alban.andrieu.webmin

#git submodule deinit -f xvbf
git submodule add https://github.com/AlbanAndrieu/ansible-xvbf.git alban.andrieu.xvbf

#git submodule deinit -f zfs
git submodule add https://github.com/AlbanAndrieu/ansible-zfs.git alban.andrieu.zfs

#git clone https://github.com/ahelal/ansible-zabbix_agent zabbix_agent
git submodule add https://github.com/AlbanAndrieu/ansible-zabbix_agent.git zabbix-agent

#git clone https://github.com/ahelal/ansible-zabbix_server zabbix-server
git submodule add https://github.com/AlbanAndrieu/ansible-zabbix_server.git zabbix-server

#git submodule deinit -f locale
#git submodule add https://github.com/knopki/ansible-locale locale
git submodule add https://github.com/AlbanAndrieu/ansible-locale.git locale
#TODO maybe switch to https://github.com/nickjj/ansible-locale

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

#git submodule deinit -f jenkins-slave
git submodule add https://github.com/AlbanAndrieu/ansible-jenkins-slave.git alban.andrieu.jenkins-slave

#git submodule deinit -f jenkins-swarm
git submodule add https://github.com/AlbanAndrieu/ansible-jenkins-swarm.git alban.andrieu.jenkins-swarm

#git submodule deinit -f dropbox
git submodule add https://github.com/AlbanAndrieu/ansible-dropbox.git alban.andrieu.dropbox

#git clone https://github.com/ahelal/ansible-sonar.git sonar
git submodule add https://github.com/AlbanAndrieu/ansible-sonar.git sonar
#pull request mysql

#git submodule deinit -f selenium
git submodule add https://github.com/AlbanAndrieu/ansible-selenium.git alban.andrieu.selenium
#TOSEE https://github.com/bcoca/ansible-selenium-role.git

git submodule add https://github.com/AlbanAndrieu/ansible-nodejs.git nodejs

#git submodule deinit -f conky
git submodule add https://github.com/AlbanAndrieu/ansible-conky.git alban.andrieu.conky

#git submodule deinit -f subversion
git submodule add https://github.com/AlbanAndrieu/ansible-subversion.git alban.andrieu.subversion

#git submodule deinit -f css
git submodule add https://github.com/AlbanAndrieu/ansible-css.git alban.andrieu.css

#http://www.funix.org/fr/linux/intrusions.htm
#git clone https://github.com/geerlingguy/ansible-role-security.git security
git submodule add https://github.com/AlbanAndrieu/ansible-role-security.git security
#TODO pull request

#git submodule deinit -f zap
git submodule add https://github.com/AlbanAndrieu/ansible-zap.git alban.andrieu.zap

#git clone https://github.com/ahelal/ansible-sonatype_nexus.git nexus
git submodule add https://github.com/AlbanAndrieu/ansible-sonatype_nexus.git nexus

#git submodule deinit -f cmake
git submodule add https://github.com/AlbanAndrieu/ansible-cmake.git alban.andrieu.cmake

#git submodule deinit -f shell
git submodule add https://github.com/AlbanAndrieu/ansible-shell.git alban.andrieu.shell

#git submodule deinit -f eclipse
git submodule add https://github.com/AlbanAndrieu/ansible-eclipse.git alban.andrieu.eclipse

git submodule add https://github.com/AlbanAndrieu/ansible-sublimetext.git alban.andrieu.sublimetext

git submodule add https://github.com/AlbanAndrieu/ansible-squirrel.git alban.andrieu.squirrel

#git submodule deinit -f jboss
git submodule add https://github.com/AlbanAndrieu/ansible-jboss.git alban.andrieu.jboss

#git submodule deinit -f alban.andrieu.windows
git submodule add https://github.com/AlbanAndrieu/ansible-windows.git alban.andrieu.windows

#TODO
#git submodule update --init
#git rm --cached alban.andrieu.solaris
#git submodule add https://github.com/AlbanAndrieu/ansible-solaris.git alban.andrieu.solaris

#git submodule deinit -f cpp
git submodule add https://github.com/AlbanAndrieu/ansible-cpp.git alban.andrieu.cpp

#git submodule deinit -f pagespeed
git submodule add https://github.com/AlbanAndrieu/ansible-pagespeed.git alban.andrieu.pagespeed

git submodule add --force https://github.com/AlbanAndrieu/ansible-evasive.git alban.andrieu.evasive

git submodule add --force https://github.com/AlbanAndrieu/ansible-awstats.git alban.andrieu.awstats

#git submodule deinit -f jmeter
git submodule add https://github.com/AlbanAndrieu/ansible-jmeter.git alban.andrieu.jmeter

#git submodule deinit -f mon
git submodule add https://github.com/AlbanAndrieu/ansible-mon.git alban.andrieu.mon

#git submodule deinit -f grive
git submodule add https://github.com/AlbanAndrieu/ansible-grive.git alban.andrieu.grive

git submodule add https://github.com/Stouts/Stouts.python.git python

#git submodule deinit -f web
git submodule add https://github.com/AlbanAndrieu/ansible-web.git alban.andrieu.web

#git submodule deinit -f common
git submodule add https://github.com/AlbanAndrieu/ansible-common.git alban.andrieu.common

#git submodule deinit -f administration
git submodule add https://github.com/AlbanAndrieu/ansible-administration.git alban.andrieu.administration

#git submodule deinit -f workstation
git submodule add https://github.com/AlbanAndrieu/ansible-workstation.git alban.andrieu.workstation

#git submodule deinit -f dns
git submodule add https://github.com/AlbanAndrieu/ansible-dns.git alban.andrieu.dns

#git submodule deinit -f tomcat
git submodule add https://github.com/AlbanAndrieu/ansible-tomcat.git alban.andrieu.tomcat

#git submodule deinit -f hostname
git submodule add https://github.com/AlbanAndrieu/ansible-hostname.git alban.andrieu.hostname

#git clone https://github.com/debops/ansible-monit.git monit
git submodule add https://github.com/ANXS/monit monit

#git submodule deinit -f synergy
git submodule add https://github.com/AlbanAndrieu/ansible-synergy.git alban.andrieu.synergy

git submodule add https://github.com/AlbanAndrieu/ansible-yourkit.git alban.andrieu.yourkit
#TODO add to ansible galaxy

git submodule add https://github.com/AlbanAndrieu/ansible-visualvm.git alban.andrieu.visualvm
#TODO add to ansible galaxy

git submodule add https://github.com/AlbanAndrieu/ansible-jdiskreport.git alban.andrieu.jdiskreport
#TODO add to ansible galaxy

git submodule add https://github.com/AlbanAndrieu/ansible-private-bower.git alban.andrieu.private-bower
#TODO add to ansible galaxy

#TODO
#git submodule deinit -f ansible-role-git
#git submodule deinit -f geerlingguy.git
git submodule add https://github.com/AlbanAndrieu/ansible-role-git.git geerlingguy.git

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
#git submodule deinit -f geerlingguy.phpmyadmin
#git submodule add https://github.com/geerlingguy/ansible-role-phpmyadmin.git geerlingguy.phpmyadmin
git submodule add https://github.com/AlbanAndrieu/ansible-role-phpmyadmin.git geerlingguy.phpmyadmin
#cd roles/geerlingguy.phpmyadmin
#git remote remove origin
#git remote add origin https://github.com/AlbanAndrieu/ansible-role-phpmyadmin.git
#git remote -v
#TODO git clone https://github.com/geerlingguy/ansible-role-varnish.git varnish
git submodule add https://github.com/geerlingguy/ansible-role-samba.git geerlingguy.samba

#git clone https://github.com/valentinogagliardi/logstash-role.git logstash
#TODO merge below geerlingguy.java with other java role
git submodule add https://github.com/geerlingguy/ansible-role-java geerlingguy.java
git submodule add https://github.com/geerlingguy/ansible-role-elasticsearch.git geerlingguy.elasticsearch
#TODO SEE https://github.com/Stouts/Stouts.logstash
git submodule add https://github.com/AlbanAndrieu/ansible-role-logstash.git geerlingguy.logstash

git submodule add https://github.com/AlbanAndrieu/ansible-logstash-settings.git alban.andrieu.logstash-settings

git submodule add https://github.com/geerlingguy/ansible-role-nginx.git geerlingguy.nginx
#git clone https://github.com/geerlingguy/ansible-role-kibana.git geerlingguy.kibana
git submodule add https://github.com/AlbanAndrieu/ansible-role-kibana.git geerlingguy.kibana

git submodule add  https://github.com/sivel/ansible-newrelic.git

#SEE
#https://github.com/docker/docker-registry

#https://galaxy.ansible.com/list#/roles/527 https://github.com/ANXS/git.git see TODO
#https://galaxy.ansible.com/list#/roles/58 see TODO

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
