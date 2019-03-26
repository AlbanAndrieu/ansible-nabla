#!/bin/bash
#set -xv
shopt -s extglob

#set -ueo pipefail
set -eo pipefail

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

# shellcheck source=/dev/null
source "${WORKING_DIR}/step-0-color.sh"

readonly DOCKER_REGISTRY=${DOCKER_REGISTRY:-"https://hub.docker.com/"}
readonly DOCKER_ORGANISATION=${DOCKER_ORGANISATION:-"nabla"}
readonly DOCKER_USERNAME=${DOCKER_USERNAME:-""}
readonly DOCKER_NAME=${DOCKER_NAME:-"ansible-jenkins-slave-docker"}
#readonly DOCKER_TAG="ubuntu:16.04"
readonly DOCKER_TAG=${DOCKER_TAG:-"latest"}

# shellcheck source=/dev/null
source "${WORKING_DIR}/run-ansible.sh"

#echo -e "${green} Installing roles version ${NC}"
#ansible-galaxy install -r requirements.yml -p ./roles/ --ignore-errors

if [ -n "${DOCKER_BUILD_ARGS}" ]; then
  echo -e "${green} DOCKER_BUILD_ARGS is defined ${happy_smiley} : ${DOCKER_BUILD_ARGS} ${NC}"
else
  echo -e "${red} ${double_arrow} Undefined build parameter ${head_skull} : DOCKER_BUILD_ARGS, use the default one ${NC}"
  export DOCKER_BUILD_ARGS="--pull"
  #export DOCKER_BUILD_ARGS="--build-arg --no-cache"
  echo -e "${magenta} DOCKER_BUILD_ARGS : ${DOCKER_BUILD_ARGS} ${NC}"
fi

echo -e "${green} Building docker image ${NC}"
echo -e "${magenta} time docker build ${DOCKER_BUILD_ARGS} -f ${WORKING_DIR}/../docker/ubuntu18/Dockerfile -t \"$DOCKER_ORGANISATION/$DOCKER_NAME\" ${WORKING_DIR}/../ --tag \"$DOCKER_TAG\" ${NC}"
time docker build ${DOCKER_BUILD_ARGS} -f ${WORKING_DIR}/../docker/ubuntu18/Dockerfile -t "${DOCKER_ORGANISATION}/${DOCKER_NAME}" ${WORKING_DIR}/../ --tag "${DOCKER_TAG}"
RC=$?
if [ ${RC} -ne 0 ]; then
  echo ""
  echo -e "${red} ${head_skull} Sorry, build failed. ${NC}"
  exit 1
else
  echo -e "${green} The build completed successfully. ${NC}"
fi

echo -e ""
echo -e "${green} This image is a trusted docker hub Image. ${happy_smiley} ${NC}"
echo -e "See https://hub.docker.com/r/nabla/ansible-jenkins-slave-docker/"
echo -e ""
echo -e "To push it"
echo -e "    docker login ${DOCKER_REGISTRY} --username ${DOCKER_USERNAME} --password password"
echo -e "    docker tag ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest ${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}"
echo -e "    docker push ${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}"
echo -e ""
echo -e "To pull it"
echo -e "    docker pull ${DOCKER_REGISTRY}${DOCKER_ORGANISATION}/${DOCKER_NAME}:${DOCKER_TAG}"
echo -e ""
echo -e "To use this docker:"
echo -e "    docker run -d -P ${DOCKER_ORGANISATION}/${DOCKER_NAME}"
echo -e " - to attach your container directly to the host's network interfaces"
echo -e "    docker run --net host -d -P ${DOCKER_ORGANISATION}/${DOCKER_NAME}"
echo -e ""
echo -e "To run in interactive mode for debug:"
echo -e "    docker run -it -u 1004:999 -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /var/run/docker.sock:/var/run/docker.sock --entrypoint /bin/bash ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest"
echo -e "    docker run -it -d -u 1004:999 --name sandbox ${DOCKER_ORGANISATION}/${DOCKER_NAME}:latest cat"
echo -e "    docker exec -it sandbox /bin/bash"
echo -e "    docker exec -u 0 -it sandbox env TERM=xterm-256color bash -l"
echo -e ""

exit 0
