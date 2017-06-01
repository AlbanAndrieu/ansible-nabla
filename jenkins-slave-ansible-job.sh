#!/bin/bash
#set -xv

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

if [ -n "${TARGET_SLAVE}" ]; then
  echo -e "TARGET_SLAVE is defined \u061F"
else
  echo -e "${red} \u00BB Undefined build parameter: TARGET_SLAVE, use the default one ${NC}"
  export TARGET_SLAVE=localhost
fi

if [ -n "${DRY_RUN}" ]; then
  echo -e "DRY_RUN is defined \u061F"
else
  echo -e "${red} \u00BB Undefined build parameter: DRY_RUN, use the default one ${NC}"
  export DRY_RUN="--check"
fi

if [ -n "${TARGET_USER}" ]; then
  echo -e "TARGET_USER is defined \u263A"
else
  echo -e "${red} \u00BB Undefined build parameter: TARGET_USER, use the default one ${NC}"
  export TARGET_USER="kgr_mvn"
fi

lsb_release -a

echo -e " ======= Running on ${TARGET_SLAVE} \u00A1 ${NC}"
echo "USER : $USER"
echo "HOME : $HOME"
echo "WORKSPACE : $WORKSPACE"

echo -e "${red} Find stale processes ${NC}"

find /proc -maxdepth 1 -user ${TARGET_USER} -type d -mmin +200 -exec basename {} \; | xargs ps -edf
echo -e "${red} Killing stale grunt processes ${NC}"
find /proc -maxdepth 1 -user ${TARGET_USER} -type d -mmin +200 -exec basename {} \; | xargs ps | grep grunt | awk '{ print $1 }' | sudo xargs kill
echo -e "${red} Killing stale google/chrome processes ${NC}"
find /proc -maxdepth 1 -user ${TARGET_USER} -type d -mmin +200 -exec basename {} \; | xargs ps | grep google/chrome | awk '{ print $1 }' | sudo xargs kill
echo -e "${red} Killing stale chromedriver processes ${NC}"
find /proc -maxdepth 1 -user ${TARGET_USER} -type d -mmin +200 -exec basename {} \; | xargs ps | grep chromedriver | awk '{ print $1 }' | sudo xargs kill
echo -e "${red} Killing stale selenium processes ${NC}"
find /proc -maxdepth 1 -user ${TARGET_USER} -type d -mmin +200 -exec basename {} \; | xargs ps | grep selenium | awk '{ print $1 }' | sudo xargs kill
echo -e "${red} Killing stale zaproxy processes ${NC}"
find /proc -maxdepth 1 -user ${TARGET_USER} -type d -mmin +200 -exec basename {} \; | xargs ps | grep ZAPROXY | awk '{ print $1 }' | sudo xargs kill

echo -e "${red} Configure workstation ${NC}"

#todo use virtualenv

echo "Switch to python 2.7 and ansible 2.1.1"
#scl enable python27 bash
#Enable python 2.7 and switch to ansible 2.1.1
#source /opt/rh/python27/enable

type -p ansible-playbook > /dev/null
if [ $? -ne 0 ]; then
    echo -e "Oops! I cannot find ansible.  Please be sure to install ansible before proceeding."
    echo -e "For guidance on installing ansible, consult http://docs.ansible.com/intro_installation.html."
    exit 1
fi

# Allow exit codes to trickle through a pipe
set -o pipefail

#TIMESTAMP=$(date --utc +"%F-%T")

# When using an interactive shell, force colorized ansible output
if [ -t "0" ]; then
    ANSIBLE_FORCE_COLOR=True
fi

echo -e "${green} Checking version ${NC}"


#todo use virtualenv

#vagrant --version
#docker --version

python --version
pip --version
ansible --version
ansible-galaxy --version

#sudo pip install https://github.com/diyan/pywinrm/archive/df049454a9309280866e0156805ccda12d71c93a.zip --upgrade
#sudo pip install ansible-lint

cd ${WORKSPACE}/

echo -e "${green} Insalling roles version ${NC}"
ansible-galaxy install -r requirements.yml -p ./roles/ --ignore-errors

git pull origin master && git submodule init && git submodule update && git submodule status || exit 1
git submodule foreach git checkout master || exit 2

export ANSIBLE_REMOTE_USER=vagrant
export ANSIBLE_PRIVATE_KEY_FILE=$HOME/.vagrant.d/insecure_private_key
ssh-add $ANSIBLE_PRIVATE_KEY_FILE

cd ${WORKSPACE}/playbooks

echo -e "${green} Display setup ${NC}"
ansible -m setup ${TARGET_SLAVE} -i hosts -vvvv

# check quality
ansible-lint nabla.yml || exit 3

#List hosts
ansible-playbook -i hosts -v nabla.yml --list-hosts || exit 3

#List tasks
ansible-playbook -i hosts -v nabla.yml --limit ${TARGET_SLAVE} --list-tasks || exit 4

#Check syntax
# check syntax 
ansible-playbook -i hosts -c local -v nabla.yml --limit ${TARGET_SLAVE} -vvvv --syntax-check
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} Sorry, syntax-check failed ${NC}"
  exit 1
else
  echo -e "${green} The syntax-check completed successfully. ${NC}"
fi

#Run ansible
#./setup.sh
ansible-playbook -i hosts nabla.yml -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN}
RC=$?
if [ ${RC} -ne 0 ]; then
  echo -e "${red} Sorry, playboook failed ${NC}"
  #exit 1
else
  echo -e "${green} playboook first try succeed. ${NC}"
  ansible-playbook -i hosts nabla.yml -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN} | grep -q 'unreachable=0.*failed=0' && (echo 'Main test: pass' && exit 0) || (echo 'Main test: fail' && exit 1)
  #--extra-vars "jenkins_username=${JENKINS_USERNAME} jenkins_password=${JENKINS_PASSWORD}"
  #./setup.sh | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)

  echo -e "${green} Ansible done. $? ${NC}"  
fi

#sudo chkrootkit

cd ${WORKSPACE}/

shellcheck *.sh -f checkstyle > checkstyle-result.xml || true
echo -e "${green} shell check for release done. $? ${NC}"

pylint **/*.py
echo -e "${green} pyhton check for shell done. $? ${NC}"

exit 0
