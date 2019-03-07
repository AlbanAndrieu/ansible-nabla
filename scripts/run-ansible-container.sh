#!/bin/bash
#set -xve

if [ -d "${WORKSPACE}/ansible" ]; then
  cd "${WORKSPACE}/ansible"
fi

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

source ${WORKING_DIR}/run-python.sh
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, python basics failed ${NC}"
  exit 1
fi

source ${WORKING_DIR}/run-ansible.sh
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, ansible basics failed ${NC}"
  exit 1
fi

# check syntax
echo -e "${cyan} =========== ${NC}"
echo -e "${green} Starting the syntax-check. ${NC}"
echo -e "${magenta} ${ANSIBLE_PLAYBOOK_CMD} -i inventory/${ANSIBLE_INVENTORY} -c local -v playbooks/${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} ${DRY_RUN} -vvvv --syntax-check --become-method=sudo ${NC}"
${ANSIBLE_PLAYBOOK_CMD} -i inventory/${ANSIBLE_INVENTORY} -v playbooks/${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} ${DRY_RUN} -vvvv --syntax-check --become-method=sudo
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, syntax-check failed ${NC}"
  exit 1
else
  echo -e "${green} The syntax-check completed successfully. ${NC}"
fi

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Starting the playbook. ${NC}"
# --ask-sudo-pass
echo -e "${magenta} ${ANSIBLE_PLAYBOOK_CMD} -i inventory/${ANSIBLE_INVENTORY} -c local -v playbooks/${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} --become-method=sudo -vvvv ${NC}"
${ANSIBLE_PLAYBOOK_CMD} -i inventory/${ANSIBLE_INVENTORY} -v playbooks/${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} --become-method=sudo -vvvv

#deactivate

#sleep 20m

docker ps -a

exit 0
