#!/bin/bash
#set -xve

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# Forcing ansible cmd to use python3.6
export PYTHON_MAJOR_VERSION=3.6
source ${WORKING_DIR}/run-python.sh
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, python 3.6 basics failed ${NC}"
  exit 1
fi

source ${WORKING_DIR}/run-ansible.sh
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, ansible basics failed ${NC}"
  exit 1
fi

rm -Rf ${JUNIT_OUTPUT_DIR} || true
mkdir ${JUNIT_OUTPUT_DIR}

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Ansible lint ${NC}"
echo -e "${magenta} ${ANSIBLE_LINT_CMD} -p playbooks/${TARGET_PLAYBOOK} > ${JUNIT_OUTPUT_DIR}/ansible-lint.txt ${NC}"
${ANSIBLE_LINT_CMD} -p playbooks/${TARGET_PLAYBOOK} > ${JUNIT_OUTPUT_DIR}/ansible-lint.txt
echo -e "${magenta} ansible-lint-junit ${JUNIT_OUTPUT_DIR}/ansible-lint.txt -o ${JUNIT_OUTPUT_DIR}/ansible-lint.xml ${NC}"
ansible-lint-junit ${JUNIT_OUTPUT_DIR}/ansible-lint.txt -o ${JUNIT_OUTPUT_DIR}/ansible-lint.xml

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Ansible server setup ${NC}"
echo -e "${magenta} ${ANSIBLE_CMD} -i inventory/${ANSIBLE_INVENTORY} -m setup --user=root -vvv --tree ${JUNIT_OUTPUT_DIR} all ${NC}"
${ANSIBLE_CMD} -i inventory/${ANSIBLE_INVENTORY} -m setup --user=root -vvvv --tree ${JUNIT_OUTPUT_DIR} all 2>&1 > inventory-setup.log
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${yellow} Warning, setup failed ${NC}"
  #This might fail for hosts which are UNREACHABLE
  #exit 1
else
  echo -e "${green} The setup completed successfully. ${NC}"
fi

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Ansible server inventory HTML generation ${NC}"
rm -Rf ${ANSIBLE_INVENTORY_OUTPUT_DIR} || true
mkdir ${ANSIBLE_INVENTORY_OUTPUT_DIR}
${ANSIBLE_CMBD_CMD} --version
echo -e "${magenta} ${ANSIBLE_CMBD_CMD} -d -i inventory/${ANSIBLE_INVENTORY} ${ANSIBLE_INVENTORY_OUTPUT_DIR} > overview.html ${NC}"
${ANSIBLE_CMBD_CMD} -d -i inventory/${ANSIBLE_INVENTORY} ${ANSIBLE_INVENTORY_OUTPUT_DIR} > overview.html
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, inventory generation failed ${NC}"
  exit 1
else
  echo -e "${green} The inventory generation completed successfully. ${NC}"
fi
echo -e "${magenta} cp overview.html /var/www/html/ ${NC}"
cp overview.html /var/www/html/ || true
echo -e "${green} Ansible server summary done. $? ${NC}"

echo -e "${green} See http://${TARGET_SLAVE}/html/overview.html ${NC}"

exit 0
