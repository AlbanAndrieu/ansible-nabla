
# Add the remote, call it "upstream":

git remote add upstream https://github.com/Stouts/Stouts.jenkins.git
git remote add upstream https://github.com/silpion/ansible-java.git
git remote add upstream https://github.com/ahelal/ansible-sonar.git
git remote add upstream https://github.com/kost/ansible-galaxy.ubuntu.virtualbox.git
git remote add upstream https://github.com/angstwad/docker.ubuntu.git
git remote add upstream https://github.com/geerlingguy/ansible-role-security.git
git remote add upstream https://github.com/geerlingguy/ansible-role-phpmyadmin.git
git remote add upstream https://github.com/ahelal/ansible-sonatype_nexus.git
git remote add upstream https://github.com/nickjj/ansigenome.git
git remote add upstream https://github.com/silpion/ansible-maven.git
git remote add upstream https://github.com/klynch/ansible-vagrant-role.git
git remote add upstream https://github.com/Stouts/Stouts.collectd.git
git remote add upstream https://github.com/Stouts/Stouts.collectd.git
git remote add upstream https://github.com/TeamPraxis/grunt-zaproxy.git
git remote add upstream https://github.com/geerlingguy/ansible-role-kibana.git
git remote add upstream https://github.com/geerlingguy/ansible-role-elasticsearch-curator.git
git remote add upstream https://github.com/geerlingguy/ansible-role-elasticsearch.git
git remote add upstream https://github.com/geerlingguy/ansible-role-mysql.git
git remote add upstream https://github.com/klynch/ansible-vagrant-role.git
git remote add upstream https://github.com/ahelal/ansible-sonar.git
git remote add upstream https://github.com/geerlingguy/ansible-role-logstash
git remote add upstream https://github.com/Stouts/Stouts.jenkins.git
git remote add upstream https://github.com/Stouts/Stouts.collectd.git
git remote add upstream https://github.com/ahelal/ansible-zabbix.git
#TODO MOVED so NOK : git remote add upstream https://github.com/ahelal/ansible-zabbix_agent.git
git remote add upstream https://github.com/AlbanAndrieu/ansible-supervisor_task.git
git remote add upstream https://github.com/AnsibleShipyard/ansible-nodejs.git
git remote add upstream https://github.com/geerlingguy/ansible-role-git.git
git remote add upstream https://github.com/silpion/ansible-util.git
git remote add upstream https://github.com/Stouts/Stouts.python.giti
git remote add upstream https://github.com/geerlingguy/ansible-role-git.git
git remote add upstream https://github.com/alourie/devbox.chrome.git
git remote add upstream https://github.com/geerlingguy/ansible-role-ntp.git

#git remote rm origin
#git remote add origin https://github.com/AlbanAndrieu/ansible-role-elasticsearch-curator.git

git remote -v

# Fetch all the branches of that remote into remote-tracking branches,
# such as upstream/master:

#git remote update
git fetch upstream

# Make sure that you're on your master branch:

git checkout master

# Rewrite your master branch so that any commits of yours that
# aren't already in upstream/master are replayed on top of that
# other branch:

git rebase upstream/master
#git rebase origin/develop
git rebase --continue

#Clean and restart from scratch
#git reset --hard upstream/master

git push origin master --force

#git branch --set-upstream-to master origin/master
