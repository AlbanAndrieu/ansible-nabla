#!/bin/bash
#set -xv

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

#mkdir ./target/ || true
#cp ${WORKING_DIR}/target/test.war ./target/

# shellcheck disable=SC2154
echo -e "${magenta} Building TEST runtime image ${NC}"
# shellcheck disable=SC2154
echo -e "${green} pip install docker-compose==1.23.2 ${NC}"

if [ -n "${DOCKER_BUILD_ARGS}" ]; then
  # shellcheck disable=SC2154
  echo -e "${green} DOCKER_BUILD_ARGS is defined ${happy_smiley} : ${DOCKER_BUILD_ARGS} ${NC}"
else
  # shellcheck disable=SC2154
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : DOCKER_BUILD_ARGS, use the default one ${NC}"
  export DOCKER_BUILD_ARGS="--pull"
  #export DOCKER_BUILD_ARGS="--build-arg --no-cache"
  echo -e "${magenta} DOCKER_BUILD_ARGS : ${DOCKER_BUILD_ARGS} ${NC}"
fi

readonly DOCKER_REGISTRY=${DOCKER_REGISTRY:-"https://hub.docker.com/"}
readonly DOCKER_ORGANISATION=${DOCKER_ORGANISATION:-"nabla"}
readonly DOCKER_USERNAME=${DOCKER_USERNAME:-""}
export DOCKER_NAME=${DOCKER_NAME:-"ansible-jenkins-slave-docker"}
export DOCKER_TAG=${DOCKER_TAG:-"latest"}
