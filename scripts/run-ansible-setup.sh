#!/bin/bash
#set -xve

echo -e "${red} Configure workstation ${NC}"

if [ -d "${WORKSPACE}/ansible" ]; then
  cd "${WORKSPACE}/ansible" || return
  #Below workaround for ansible plugins in jenkins (vault not found)
  cp ansible.cfg vault.passwd ${WORKSPACE} || true
fi

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Installing roles version ${NC}"
echo -e "${magenta} ${ANSIBLE_GALAXY_CMD} install -r ${WORKING_DIR}/../requirements.yml -p ${WORKING_DIR}/../roles/ --ignore-errors --force ${NC}"
${ANSIBLE_GALAXY_CMD} install -r ${WORKING_DIR}/../requirements.yml -p ${WORKING_DIR}/../roles/ --ignore-errors --force

export ANSIBLE_CONFIG=${WORKING_DIR}/../ansible.cfg
export PROFILE_TASKS_SORT_ORDER=none
export PROFILE_TASKS_TASK_OUTPUT_LIMIT=all

echo -e "${cyan} =========== ${NC}"
echo -e "${green} Display setup ${NC}"
echo -e "${magenta} ${ANSIBLE_CMD} -m setup ${TARGET_SLAVE} -i ${WORKING_DIR}/../inventory/${ANSIBLE_INVENTORY} -vvvv ${NC}"
${ANSIBLE_CMD} -m setup ${TARGET_SLAVE} -i ${WORKING_DIR}/../inventory/${ANSIBLE_INVENTORY} -vvvv
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, ansible setup failed ${NC}"
  exit 1
else
  echo -e "${green} The ansible setup check completed successfully. ${NC}"
fi
