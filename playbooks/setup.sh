#!/bin/bash
#set -xv

#export bold="\033[01m"
#export underline="\033[04m"
#export blink="\033[05m"

#export black="\033[30m"
export red="\033[31m"
export green="\033[32m"
#export yellow="\033[33m"
#export blue="\033[34m"
export magenta="\033[35m"
#export cyan="\033[36m"
#export ltgray="\033[37m"

export NC="\033[0m"

#export double_arrow='\xC2\xBB'
export head_skull='\xE2\x98\xA0'
export happy_smiley='\xE2\x98\xBA'
# shellcheck disable=SC2034
export reverse_exclamation='\u00A1'

if [ -n "${TARGET_SLAVE}" ]; then
  echo -e "${green} TARGET_SLAVE is defined ${happy_smiley} : ${TARGET_SLAVE} ${NC}"
else
  echo -e "${red} \u00BB Undefined build parameter ${head_skull} : TARGET_SLAVE, use the default one ${NC}"
  export TARGET_SLAVE=localhost
  echo -e "${magenta} TARGET_SLAVE : ${TARGET_SLAVE} ${NC}"
fi

if [ -n "${TARGET_PLAYBOOK}" ]; then
  echo -e "${green} TARGET_PLAYBOOK is defined ${happy_smiley} : ${TARGET_PLAYBOOK} ${NC}"
else
  echo -e "${red} \u00BB Undefined build parameter ${head_skull} : TARGET_PLAYBOOK, use the default one ${NC}"
  export TARGET_PLAYBOOK=nabla.yml
  echo -e "${magenta} TARGET_PLAYBOOK : ${TARGET_PLAYBOOK} ${NC}"
fi

if [ -n "${DRY_RUN}" ]; then
  echo -e "${green} DRY_RUN is defined ${happy_smiley} : ${DRY_RUN} ${NC}"
else
  echo -e "${red} \u00BB Undefined build parameter ${head_skull} : DRY_RUN, use the default one ${NC}"
  export DRY_RUN="--check"
  echo -e "${magenta} DRY_RUN : ${DRY_RUN} ${NC}"
fi

type -p "${ANSIBLE_PLAYBOOK_CMD}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${red} \u00BB Oops! I cannot find ansible.  Please be sure to install ansible before proceeding. ${NC}"
    echo -e "${red} \u00BB For guidance on installing ansible, consult http://docs.ansible.com/intro_installation.html. ${NC}"
    exit 1
fi

#export ANSIBLE_DEBUG=1

# Allow exit codes to trickle through a pipe
set -o pipefail

TIMESTAMP=$(date --utc +"%F-%T")
LOG_DIR="/var/log/awx"
LOG_FILE="${LOG_DIR}/setup-${TIMESTAMP}.log"

# When using an interactive shell, force colorized ansible output
if [ -t "0" ]; then
    ANSIBLE_FORCE_COLOR=True
fi

# shellcheck disable=SC2034
getopts "e:" EXTRA_ARGS
if [ "$OPTARG" != "" ]; then
    echo -e "${green} Running with extra args: ${OPTARG} ${NC}"
    echo -e "${magenta} x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR ANSIBLE_ERROR_ON_UNDEFINED_VARS=True ${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN} -e \"$OPTARG\" ${TARGET_PLAYBOOK} ${NC}"
    PYTHONUNBUFFERED=x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR ANSIBLE_ERROR_ON_UNDEFINED_VARS=True ${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN} -e "$OPTARG" ${TARGET_PLAYBOOK} | tee setup.log
else
    echo -e "${magenta} x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR ANSIBLE_ERROR_ON_UNDEFINED_VARS=True ${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN} ${TARGET_PLAYBOOK} -vvvv ${NC}"
    PYTHONUNBUFFERED=x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR ANSIBLE_ERROR_ON_UNDEFINED_VARS=True ${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN} ${TARGET_PLAYBOOK} | tee setup.log
fi
RC=$?
if [ ${RC} -ne 0 ]; then
    echo -e "${red} ${head_skull} Sorry, playboook failed ${NC}"
else
    echo -e "${green} playboook succeed. ${NC}"
    #${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} ${TARGET_PLAYBOOK} -vvvv --limit ${TARGET_SLAVE} ${DRY_RUN} --become-method=sudo | grep -q 'unreachable=0.*failed=0' && (echo 'Main test: pass' && exit 0) || (echo 'Main test: fail' && exit 1)
fi

echo -e "${green} Ansible done. $? ${NC}"

# Save logfile
if [ -d "${LOG_DIR}" ]; then
    sudo cp setup.log "${LOG_FILE}"
    echo -e "${green} Setup log saved to ${LOG_FILE} ${NC}"
fi

exit ${RC}
