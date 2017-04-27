#!/bin/bash
#set -xv

red='\e[0;31m'
green='\e[0;32m'
NC='\e[0m' # No Color

type -p ansible-playbook > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${red} Oops! I cannot find ansible.  Please be sure to install ansible before proceeding. ${NC}"
    echo -e "For guidance on installing ansible, consult http://docs.ansible.com/intro_installation.html."
    exit 1
fi

# Allow exit codes to trickle through a pipe
set -o pipefail

TIMESTAMP=$(date --utc +"%F-%T")
LOG_DIR="/var/log/awx"
LOG_FILE="${LOG_DIR}/setup-${TIMESTAMP}.log"

# When using an interactive shell, force colorized ansible output
if [ -t "0" ]; then
    ANSIBLE_FORCE_COLOR=True
fi

getopts "e:" EXTRA_ARGS
if [ "$OPTARG" != "" ]; then
    echo "Running with extra args: ${OPTARG}"
    PYTHONUNBUFFERED=x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR ANSIBLE_ERROR_ON_UNDEFINED_VARS=True ansible-playbook -i hosts -c local -v -e "$OPTARG" nabla.yml | tee setup.log
else
    PYTHONUNBUFFERED=x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR ANSIBLE_ERROR_ON_UNDEFINED_VARS=True ansible-playbook -i hosts -c local -v nabla.yml -vvvv | tee setup.log
fi
RC=$?
if [ ${RC} -ne 0 ]; then
    echo -e "${red} Oops!  An error occured while running setup. ${NC}"
else
    echo -e "${green} The setup process completed successfully. ${NC}"
fi

# Save logfile
if [ -d "${LOG_DIR}" ]; then
    cp setup.log "${LOG_FILE}"
    echo -e "${green} Setup log saved to ${LOG_FILE} ${NC}"
fi

exit ${RC}
