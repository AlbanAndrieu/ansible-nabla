#!/bin/bash
#set -xve

if [ -d "${WORKSPACE}/ansible" ]; then
  cd "${WORKSPACE}/ansible"
fi

source ./run-ansible.sh
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, ansible basics failed ${NC}"
  exit 1
fi

# check syntax
echo -e "${cyan} =========== ${NC}"
echo -e "${green} Starting the syntax-check. ${NC}"
echo -e "${magenta} ${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -c local -v ${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} ${DRY_RUN} -vvvv --syntax-check --become-method=sudo ${NC}"
${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -v ${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} ${DRY_RUN} -vvvv --syntax-check --become-method=sudo
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, syntax-check failed ${NC}"
  exit 1
else
  echo -e "${green} The syntax-check completed successfully. ${NC}"
fi

# check quality
#${ANSIBLE_LINT_CMD} ${TARGET_PLAYBOOK}

# check syntax
#${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -c local -v ${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} -vvvv --syntax-check

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Starting the playbook. ${NC}"
# --ask-sudo-pass
echo -e "${magenta} ${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -c local -v ${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} --become-method=sudo -vvvv ${NC}"
${ANSIBLE_PLAYBOOK_CMD} -i ${ANSIBLE_INVENTORY} -v ${TARGET_PLAYBOOK} --limit ${TARGET_SLAVE} --become-method=sudo -vvvv

#deactivate

#sleep 20m

docker ps

exit 0
