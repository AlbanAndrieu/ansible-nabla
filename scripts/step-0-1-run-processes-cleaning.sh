#!/bin/bash
#set -xv

source ./step-0-color.sh

if [ -n "${TARGET_USER}" ]; then
  # shellcheck disable=SC2154
  echo -e "${green} TARGET_USER is defined ${happy_smiley} ${NC}"
else
  # shellcheck disable=SC2154
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : TARGET_USER, use the default one ${NC}"
  export TARGET_USER="jenkins"
fi

echo -e "${red} Find stale processes ${NC}"

function kill_matching_processes
{
  local process_name_matcher="$1"
  # shellcheck disable=SC2038
  find /proc -maxdepth 1 -user "${TARGET_USER}" -type d -mmin +200 -exec basename {} \; | xargs ps | grep "${process_name_matcher}" | awk '{ print $1 }'
  # shellcheck disable=SC2038
  find /proc -maxdepth 1 -user "${TARGET_USER}" -type d -mmin +200 -exec basename {} \; | xargs ps | grep "${process_name_matcher}" | awk '{ print $1 }' | sudo xargs kill -9 || true
}

find /proc -maxdepth 1 -user "${TARGET_USER}" -type d -print0 -mmin +200 -exec basename {} \; | xargs ps

echo -e "${red} Killing stale grunt processes ${head_skull} ${NC}"
kill_matching_processes grunt
echo -e "${red} Killing stale google/chrome processes ${head_skull} ${NC}"
kill_matching_processes google/chrome
echo -e "${red} Killing stale chromedriver processes ${head_skull} ${NC}"
kill_matching_processes chromedriver
echo -e "${red} Killing stale selenium processes ${head_skull} ${NC}"
kill_matching_processes selenium
echo -e "${red} Killing stale zaproxy processes ${head_skull} ${NC}"
kill_matching_processes ZAPROXY
echo -e "${red} Killing stale jboss processes ${head_skull} ${NC}"
kill_matching_processes jboss-modules

exit 0
