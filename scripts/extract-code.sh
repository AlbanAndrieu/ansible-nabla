#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

#create a git local repo
#touch README.md
#git init
#git add README.md
#git commit -m "first commit"
#git remote add origin https://github.com/AlbanAndrieu/ansible-swarm.git
#git push -u origin master

git clone https://github.com/AlbanAndrieu/ansible-nabla.git ansible-nabla

git pull && git submodule init && git submodule update && git submodule status
#git fetch --recurse-submodules
#git submodule foreach git fetch
git submodule foreach git checkout master
git submodule foreach git pull origin master

git submodule add https://github.com/AlbanAndrieu/ansigenome.git

ansible-galaxy install -r ../requirements.yml -p ../roles/ --ignore-errors

mkdir roles

cd roles

#git clone https://github.com/debops/ansible-role-ansible.git ansible
#git submodule deinit -f ansible
#rm -rf ../.git/modules/roles/ansible/
git submodule add -f  https://github.com/debops/ansible-role-ansible.git ansible

#git clone https://github.com/EDITD/ansible-supervisor_task.git supervisor
git submodule add -f  https://github.com/AlbanAndrieu/ansible-supervisor_task.git supervisor
#pull request pending

#git submodule deinit -f webmin
#rm -rf ../.git/modules/roles/webmin/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-webmin.git alban.andrieu.webmin

#git submodule deinit -f xvbf
#rm -rf ../.git/modules/roles/xvbf/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-xvbf.git alban.andrieu.xvbf

#git submodule deinit -f zfs
#rm -rf ../.git/modules/roles/zfs/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-zfs.git alban.andrieu.zfs

#git clone https://github.com/dj-wasabi/ansible-zabbix-agent zabbix
#git submodule add -f  https://github.com/dj-wasabi/ansible-zabbix-agent.git zabbix

#git submodule deinit -f locale
#git submodule add -f  https://github.com/knopki/ansible-locale locale
#TODO REMOVE git submodule add -f  https://github.com/AlbanAndrieu/ansible-locale.git locale
git submodule add -f  https://github.com/Oefenweb/ansible-locales locale
#TODO maybe switch to https://github.com/nickjj/ansible-locale

#git clone https://github.com/kost/ansible-galaxy.ubuntu.virtualbox.git virtualbox
git submodule add -f  https://github.com/AlbanAndrieu/ansible-galaxy.ubuntu.virtualbox.git alban.andrieu.virtualbox

#git clone https://github.com/aw/ansible-galaxy-vagrant.git vagrant-user
#git submodule add -f  https://github.com/AlbanAndrieu/ansible-galaxy-vagrant.git vagrant-user

#git clone https://github.com/klynch/ansible-vagrant-role.git vagrant
#TODO switch
git submodule add -f  https://github.com/AlbanAndrieu/ansible-vagrant-role.git vagrant

#TODO control vagrant with ansible https://github.com/robparrott/ansible-vagrant

#git clone https://github.com/angstwad/docker.ubuntu.git docker
git submodule add -f  https://github.com/AlbanAndrieu/docker.ubuntu.git docker

git submodule add -f  https://github.com/AlbanAndrieu/ansible-util.git silpion.util
git submodule add -f  https://github.com/AlbanAndrieu/ansible-lib.git silpion.lib

#git clone https://github.com/silpion/ansible-maven maven
git submodule deinit -f maven
git rm --cached maven
git submodule add -f  https://github.com/AlbanAndrieu/ansible-maven.git maven
#TODO rename to silpion.maven
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-maven.git maven
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-maven-color.git maven-color

#git submodule deinit -f java
#rm -rf ../.git/modules/roles/java/
#git submodule add -f  https://github.com/AlbanAndrieu/ansible-java.git java
git submodule add -f  https://github.com/ansiblebit/oracle-java java
#pull request pending

#git submodule deinit -f chrome
#git clone https://github.com/alourie/devbox.chrome.git devbox.chrome
#git submodule add -f  https://github.com/AlbanAndrieu/devbox.chrome.git chrome

#git clone https://github.com/Stouts/Stouts.jenkins.git jenkins-master
git submodule add -f  https://github.com/AlbanAndrieu/Stouts.jenkins.git jenkins-master

#git submodule deinit -f jenkins-slave
git submodule add -f  https://github.com/AlbanAndrieu/ansible-jenkins-slave.git alban.andrieu.jenkins-slave

#git submodule deinit -f jenkins-swarm
git submodule add -f  https://github.com/AlbanAndrieu/ansible-jenkins-swarm.git alban.andrieu.jenkins-swarm

#git submodule deinit -f dropbox
git submodule add -f  https://github.com/AlbanAndrieu/ansible-dropbox.git alban.andrieu.dropbox

#git clone https://github.com/ahelal/ansible-sonar.git sonar
git submodule add -f  https://github.com/AlbanAndrieu/ansible-sonar.git sonar
#pull request mysql

#git submodule deinit -f selenium
git submodule add -f  https://github.com/AlbanAndrieu/ansible-selenium.git alban.andrieu.selenium
#TOSEE https://github.com/bcoca/ansible-selenium-role.git

#git submodule deinit -f nodejs
#rm -rf ../.git/modules/roles/nodejs/
#git rm --cached nodejs
git submodule deinit -f nodejs
git submodule deinit -f geerlingguy.nodejs
#TO REMOVE
#git submodule add -f  https://github.com/AlbanAndrieu/ansible-nodejs.git nodejs
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-nodejs.git geerlingguy.nodejs

#git submodule deinit -f conky
git submodule add -f  https://github.com/AlbanAndrieu/ansible-conky.git alban.andrieu.conky

#git submodule deinit -f subversion
git submodule add -f  https://github.com/AlbanAndrieu/ansible-subversion.git alban.andrieu.subversion

#git submodule deinit -f css
git submodule add -f  https://github.com/AlbanAndrieu/ansible-css.git alban.andrieu.css

#http://www.funix.org/fr/linux/intrusions.htm
#git submodule deinit -f security
#rm -rf ../.git/modules/roles/security/
#git rm --cached security
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-security.git security
git submodule add -f  https://github.com/AlbanAndrieu/ansible-login.git ansible-login

#git submodule deinit -f zap
git submodule add -f  https://github.com/AlbanAndrieu/ansible-zap.git alban.andrieu.zap

#git clone https://github.com/ahelal/ansible-sonatype_nexus.git nexus
git submodule add -f  https://github.com/AlbanAndrieu/ansible-sonatype_nexus.git nexus

#git submodule deinit -f cmake
git submodule add -f  https://github.com/AlbanAndrieu/ansible-cmake.git alban.andrieu.cmake
git submodule add -f  https://github.com/AlbanAndrieu/ansible-scons.git alban.andrieu.scons
git submodule add -f  https://github.com/AlbanAndrieu/ansible-gcc.git alban.andrieu.gcc
git submodule add -f  https://github.com/AlbanAndrieu/ansible-cpp.git alban.andrieu.cpp

#git submodule deinit -f shell
git submodule add -f  https://github.com/AlbanAndrieu/ansible-shell.git alban.andrieu.shell

#git submodule deinit -f eclipse
git submodule add -f  https://github.com/AlbanAndrieu/ansible-eclipse.git alban.andrieu.eclipse

git submodule add -f  https://github.com/AlbanAndrieu/ansible-sublimetext.git alban.andrieu.sublimetext

git submodule add -f  https://github.com/AlbanAndrieu/ansible-squirrel.git alban.andrieu.squirrel

#git submodule deinit -f jboss
git submodule add -f  https://github.com/AlbanAndrieu/ansible-jboss.git alban.andrieu.jboss

#git submodule deinit -f alban.andrieu.windows
git submodule add -f  https://github.com/AlbanAndrieu/ansible-windows.git alban.andrieu.windows

#TODO
#git submodule update --init
#git rm --cached alban.andrieu.solaris
#git submodule add -f  https://github.com/AlbanAndrieu/ansible-solaris.git alban.andrieu.solaris

#git submodule deinit -f pagespeed
git submodule add -f  https://github.com/AlbanAndrieu/ansible-pagespeed.git alban.andrieu.pagespeed

git submodule add -f  --force https://github.com/AlbanAndrieu/ansible-evasive.git alban.andrieu.evasive

git submodule add -f  --force https://github.com/AlbanAndrieu/ansible-awstats.git alban.andrieu.awstats

#git submodule deinit -f jmeter
#rm -rf ../.git/modules/roles/jmeter/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-jmeter.git alban.andrieu.jmeter

#git submodule deinit -f mon
#rm -rf ../.git/modules/roles/mon/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-mon.git alban.andrieu.mon

#git submodule deinit -f grive
#rm -rf ../.git/modules/roles/grive/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-grive.git alban.andrieu.grive

#git submodule deinit -f solaris
git submodule add -f  https://github.com/AlbanAndrieu/ansible-solaris.git alban.andrieu.solaris

#git submodule deinit -f python
#git rm python
#rm -rf ../.git/modules/roles/python/
git submodule add -f  https://github.com/AlbanAndrieu/Stouts.python.git python

#git submodule deinit -f collectd
git submodule add -f  https://github.com/AlbanAndrieu/Stouts.collectd.git collectd

#git submodule deinit -f web
git submodule add -f  https://github.com/AlbanAndrieu/ansible-web.git alban.andrieu.web

#git submodule deinit -f common
git submodule add -f  https://github.com/AlbanAndrieu/ansible-common.git alban.andrieu.common

#git submodule deinit -f administration
git submodule add -f  https://github.com/AlbanAndrieu/ansible-administration.git alban.andrieu.administration

#git submodule deinit -f workstation
git submodule add -f  https://github.com/AlbanAndrieu/ansible-workstation.git alban.andrieu.workstation

#git submodule deinit -f dns
git submodule add -f  https://github.com/AlbanAndrieu/ansible-dns.git alban.andrieu.dns

#git submodule deinit -f tomcat
git submodule add -f  https://github.com/AlbanAndrieu/ansible-tomcat.git alban.andrieu.tomcat

#git submodule deinit -f hostname
git submodule add -f  https://github.com/AlbanAndrieu/ansible-hostname.git alban.andrieu.hostname

#git clone https://github.com/debops/ansible-monit.git monit
git submodule add -f  https://github.com/ANXS/monit monit

#git submodule deinit -f synergy
git submodule add -f  https://github.com/AlbanAndrieu/ansible-synergy.git alban.andrieu.synergy

git submodule add -f  https://github.com/AlbanAndrieu/ansible-yourkit.git alban.andrieu.yourkit
#TODO add to ansible galaxy

git submodule add -f  https://github.com/AlbanAndrieu/ansible-visualvm.git alban.andrieu.visualvm
#TODO add to ansible galaxy

git submodule add -f  https://github.com/AlbanAndrieu/ansible-jdiskreport.git alban.andrieu.jdiskreport
#TODO add to ansible galaxy

git submodule add -f  https://github.com/AlbanAndrieu/ansible-private-bower.git alban.andrieu.private-bower
#TODO add to ansible galaxy

#TODO
#git submodule deinit -f ansible-role-git
#git submodule deinit -f geerlingguy.git
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-git.git geerlingguy.git

#LAMP
git submodule add -f  https://github.com/geerlingguy/ansible-role-firewall.git geerlingguy.firewall
#git submodule deinit -f geerlingguy.ntp
#rm -rf ../.git/modules/roles/geerlingguy.ntp/
#git rm --cached geerlingguy.ntp
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-ntp.git geerlingguy.ntp
git submodule add -f  https://github.com/geerlingguy/ansible-role-repo-epel.git geerlingguy.repo-epel
git submodule add -f  https://github.com/geerlingguy/ansible-role-repo-remi.git geerlingguy.repo-remi
git submodule add -f  https://github.com/geerlingguy/ansible-role-apache.git geerlingguy.apache
#see fork below git clone https://github.com/geerlingguy/ansible-role-mysql.git mysql
#see fork of fork below git clone https://github.com/augustohp/ansible-role-mysql.git mysql
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-mysql.git geerlingguy.mysql
git submodule add -f  https://github.com/geerlingguy/ansible-role-php.git geerlingguy.php
git submodule add -f  https://github.com/geerlingguy/ansible-role-php-mysql.git geerlingguy.php-mysql
#git submodule deinit -f geerlingguy.phpmyadmin
#git submodule add -f  https://github.com/geerlingguy/ansible-role-phpmyadmin.git geerlingguy.phpmyadmin
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-phpmyadmin.git geerlingguy.phpmyadmin
#cd roles/geerlingguy.phpmyadmin
#git remote remove origin
#git remote add origin https://github.com/AlbanAndrieu/ansible-role-phpmyadmin.git
#git remote -v
#TODO git clone https://github.com/geerlingguy/ansible-role-varnish.git varnish
git submodule add -f  https://github.com/geerlingguy/ansible-role-samba.git geerlingguy.samba

#git clone https://github.com/valentinogagliardi/logstash-role.git logstash
#TODO merge below geerlingguy.java with other java role
git submodule add -f  https://github.com/geerlingguy/ansible-role-java geerlingguy.java
#git submodule add -f  https://github.com/geerlingguy/ansible-role-elasticsearch.git geerlingguy.elasticsearch
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-elasticsearch.git geerlingguy.elasticsearch
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-elasticsearch-curator.git geerlingguy.elasticsearch-curator
#TODO SEE https://github.com/Stouts/Stouts.logstash
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-logstash.git geerlingguy.logstash
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-redis.git geerlingguy.redis

git submodule add -f  https://github.com/AlbanAndrieu/ansible-logstash-settings.git alban.andrieu.logstash-settings

git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-nginx.git geerlingguy.nginx
#git clone https://github.com/geerlingguy/ansible-role-kibana.git geerlingguy.kibana
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-kibana.git geerlingguy.kibana

#git submodule deinit -f ansible-newrelic
#git rm ansible-newrelic
#rm -rf ../.git/modules/roles/ansible-newrelic/
#git submodule add -f  https://github.com/sivel/ansible-newrelic.git
git submodule add -f  https://github.com/AlbanAndrieu/ansible-newrelic.git

git submodule add -f  https://github.com/AlbanAndrieu/ansible-phpvirtualbox.git alban.andrieu.phpvirtualbox

git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-wordpress.git darthwade.wordpress
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-wordpress-apache.git darthwade.wordpress-apache
#git clone https://github.com/MatthewMi11er/ansible-role-wordpress wordpress
#git submodule add -f  https://github.com/darthwade/ansible-role-wordpress-apache.git wordpress

#git rm --cached alban.andrieu.owasp-wte
git submodule add -f  https://github.com/AlbanAndrieu/ansible-owasp-wte.git alban.andrieu.owasp-wte

git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-base.git elao.base
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-ruby.git elao.ruby
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-sass.git elao.sass

#git submodule deinit -f java.certificate
#git rm java.certificate
#rm -rf ../.git/modules/roles/java.certificate/
git submodule add -f  https://github.com/AlbanAndrieu/ansible-java-certificate.git java-certificate
git submodule add -f  https://github.com/AlbanAndrieu/ansible-role-ssl-certs.git ssl-certificate
git submodule add -f  https://github.com/AlbanAndrieu/ansible-trust-ca.git ssl-ca-certificate

git submodule add -f  https://github.com/ocha/ansible-role-yarn.git yarn

#SEE
#https://github.com/docker/docker-registry

#https://galaxy.ansible.com/list#/roles/527 https://github.com/ANXS/git.git see TODO
#https://galaxy.ansible.com/list#/roles/58 see TODO

#https://github.com/ansible/ansible-examples/tree/master/language_features
#https://github.com/sheldonh/dotfiles-ansible
#https://github.com/ginas/ginas
#SEE and check
#git submodule add -f  https://github.com/major/ansible-role-cis.git security-cis

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

#https://github.com/Stouts/Stouts.backup

#Below it can be usefull for maintenance purpose
#https://github.com/mivok/ansible-users

#TODO see docker
#https://github.com/geerlingguy/docker-examples/blob/master/.travis.yml

#See https://github.com/ypid/ypid-ansible-common/tree/master/template_READMEs
TODO https://github.com/ypid/ypid-ansible-common

#sudo pip install ansigenome --upgrade
cd ${WORKING_DIR}/ansigenome ; sudo python setup.py develop

./misc/ansigenome/bin/ansigenome scan
./misc/ansigenome/bin/ansigenome gendoc -f md

#[![test-suite](https://img.shields.io/badge/test--suite-{{ scm.repo_prefix | replace("-","--") | replace("_","__") + role.name | replace("-","--") | replace("_","__") }}-blue.svg?style=flat)](https://github.com/{{ scm.user }}/test-suite/tree/master/{{ scm.repo_prefix + role.name }}/)

ansigenome export -t reqs -o ./test.yml -f yml ./roles
ansigenome export -o ./test.dot -f dot ./roles
ansigenome export -o ./test.png ./roles --size=20,20 -dpi=300

#ansigenome scan --limit roles/alban.andrieu.eclipse
#ansigenome gendoc --format=md --limit roles/alban.andrieu.eclipse

#See https://github.com/fboender/ansible-cmdb
mkdir out
#Add missing python-simplejson
ansible myserver -i hosts-production -m raw -a "sudo yum install -y python-simplejson"  -k -u root -vvvv
ansible -i hosts-production -m setup --user=root --tree out/ all
ansible-cmdb -i hosts-production out/ > overview.html

ansible-galaxy login
ansible-galaxy setup travis AlbanAndrieu ansible-jmeter Mc7ofHYG4bP5zSbuxEdQ
ansible-galaxy setup --list
#remove integration
#ansible-galaxy setup --remove ID
ansible-galaxy search eclipse --author alban.andrieu
ansible-galaxy install alban.andrieu.jmeter
#ansible-galaxy install AlbanAndrieu.java

find ./ -type f -name "*.yml" -exec chmod 644 {} +
find ./ -type f -name "*.j2" -exec chmod 644 {} +

cd ${WORKING_DIR}/alban.andrieu.webmin
molecule init scenario --scenario-name default --role-name alban.andrieu.webmin

cd ${WORKING_DIR}/alban.andrieu.virtualbox
molecule init scenario --scenario-name default --role-name alban.andrieu.virtualbox
molecule --debug converge
