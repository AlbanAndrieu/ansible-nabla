#!/bin/bash
#set -xv
shopt -s extglob

set -eo pipefail

WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DOCKER_FILE=${DOCKER_FILE:-"docker/ubuntu24/Dockerfile"}
export CST_CONFIG=${CST_CONFIG:-"docker/ubuntu24/config.yaml"}

echo -e "${green} Validating Docker ${NC}"
echo -e "${magenta} hadolint ${WORKING_DIR}/../${DOCKER_FILE} --format json ${NC}"
hadolint "${WORKING_DIR}/../${DOCKER_FILE}" --format json 1>docker-hadolint.json 2>docker-hadolint-error.log || true

exit 0
