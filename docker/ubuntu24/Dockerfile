# syntax=docker/dockerfile:1
# FROM docker.io/ubuntu:24.04 AS base
FROM selenium/standalone-chrome:4.51.0-20261010 AS base
# FROM selenium/standalone-chrome:4.25.0-20240922 AS base

# dockerfile_lint - ignore
LABEL name="nabla-ubuntu" vendor="nabla" version="2.1.0"

# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

ARG UBUNTU_USER_HOME=${UBUNTU_USER_HOME:-/home/ubuntu}
ENV UBUNTU_USER_HOME=${UBUNTU_USER_HOME:-/home/ubuntu}

#Below HOME is needed to override seluser (selenium user)
ENV HOME=${UBUNTU_USER_HOME}

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM="xterm-256color"

# checkov:skip=CKV_DOCKER_8:Ensure the last USER is not root
# hadolint ignore=DL3002
USER root

# Enable retry logic for apt up to 10 times
# Configure apt to always assume Y
RUN echo "APT::Acquire::Retries \"10\";" > /etc/apt/apt.conf.d/80-retries \
&& echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# BASE

# libffi-dev libgit2-dev needed for pip install dvc[s3]==1.11.6 pathspec==0.9.0
# openssh-client  needed for eval $(ssh-agent -s) and ssh-add
# build-essential has gcc, needed for python requirements

# hadolint ignore=DL3008
RUN apt-get -q update --fix-missing \
  && apt-get full-upgrade -y \
  && apt-get -q -o Dpkg::Options::="--force-confnew" --no-install-recommends install -y \
  git rsync curl wget bash jq \
  apt-utils apt-transport-https ca-certificates software-properties-common \
  build-essential locales \
  bzip2 zip unzip tar xz-utils gpg-agent \
  gnupg2 tzdata \
  gettext-base \
  nano \
  net-tools iputils-ping dnsutils inetutils-traceroute \
  openssh-client ssh-askpass \
  libffi-dev libgit2-dev zlib1g-dev libpq-dev \
  make maven \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# because of tzdata and the need of noninteractive
ENV TZ "Europe/Paris"
RUN echo "${TZ}" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive tzdata

FROM base as docker

ENV USER=${USER:-ubuntu}
ENV GROUP=${GROUP:-docker}
ENV UID=${UID:-2000}
ENV GID=${GID:-2000}

# hadolint ignore=SC2059
RUN printf "\033[1;32mFROM UID:GID: ${UID}:${GID} \033[0m\n" && \
  printf "\033[1;32mUBUNTU_USER_HOME: ${UBUNTU_USER_HOME} \033[0m\n" && \
  printf "\033[1;32mWITH user: ${USER}\ngroup: ${GROUP} \033[0m\n"

### DOCKER

# dockerfile_lint - ignore
ENV DOCKER_VERSION=${DOCKER_VERSION:-"29.9.2-1"}

# apt-key is deprecated, use a dedicated keyring
# hadolint ignore=DL3006,DL4006
RUN install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list
# Install Docker from Docker Inc. repositories.
# hadolint ignore=SC2046,DL3008
RUN apt-get update -qq && apt-get --no-install-recommends install -qqy \
  docker-ce=5:${DOCKER_VERSION}~ubuntu.24.04~$(lsb_release -cs) \
  docker-ce-cli=5:${DOCKER_VERSION}~ubuntu.24.04~$(lsb_release -cs) \
  docker-buildx-plugin \
  docker-compose-plugin \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# PODMAN

# hadolint ignore=DL3006,DL4006
# RUN curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key \
#   | gpg --dearmor  \
#   echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg] \
#     https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/Debian_Testing/ /" \
#   | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

# RUN sed -i "s/# unqualified-search-registries.*/unqualified-search-registries\ =\ [\"docker.io\"]/" /etc/containers/registries.conf

### USER (should follow ### DOCKER)

# Add user ubuntu to the image
# RUN groupmod -g ${GID} ${GROUP} \
# && adduser --quiet --uid ${UID} --gid ${GID} \
#   --home ${UBUNTU_USER_HOME} \
#   --disabled-password \
#   --gecos "" \
#   ${USER} \
# && usermod -a -G ${GROUP} ${USER} \
# && chown -R ${USER}:${GROUP} ${UBUNTU_USER_HOME}

#USER ${USER}

FROM docker as python

### PYTHON

# The selenium base image ships python3.14 (deadsnakes) as /usr/bin/python3,
# use it through a dedicated virtualenv instead of Ubuntu python3 packages
# checkov:skip=CKV_DOCKER_8:Ensure the last USER is not root
# hadolint ignore=DL3002
USER root

ENV PYTHON_VERSION=3.14 \
    VIRTUAL_ENV=/opt/venv

# hadolint ignore=DL3008
RUN apt-get -q update \
  && apt-get -q -o Dpkg::Options::="--force-confnew" --no-install-recommends install -y \
  python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python${PYTHON_VERSION} -m venv ${VIRTUAL_ENV}
ENV PATH=${VIRTUAL_ENV}/bin:${PATH}

### PYTHON POETRY

# Turns off buffering for easier container logging
# python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=2.5.1 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup"

# Installs Poetry in its own environment to avoid problems with Ubuntu's Python
RUN python3 -m venv $POETRY_HOME \
    && $POETRY_HOME/bin/pip3 install poetry==$POETRY_VERSION \
    && $POETRY_HOME/bin/poetry --version

### ANSIBLE CORE

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible \
  && printf "[local]\nlocalhost ansible_connection=local\n" > /etc/ansible/hosts

RUN pip install --no-cache-dir pipenv==2026.10.2 \
  && ln -sfv "${VIRTUAL_ENV}/bin/python3" /usr/bin/python

COPY Pipfile Pipfile.lock ${PYSETUP_PATH}/

WORKDIR ${PYSETUP_PATH}

# ansible-core and the other tools are pinned by Pipfile.lock,
# --system installs them in the active ${VIRTUAL_ENV}
RUN pipenv install --system --deploy --dev \
  && chown -R ${USER}:${GROUP} ${VIRTUAL_ENV}

# NODE

# checkov:skip=CKV_DOCKER_8:Ensure the last USER is not root
# hadolint ignore=DL3002
USER root

ENV NODE_VERSION=${NODE_VERSION:-"24"}

# hadolint ignore=DL3008,DL3015,DL3006,DL4006
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && apt-get install --no-install-recommends -y nodejs=${NODE_VERSION}* && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    npm set progress=false && \
    npm config set depth 0;
RUN npm install -g npm@12.2.1 && apt-get purge -y npm
RUN npm -v && command -v npm # 12.2.1
RUN npm install -g yarn@1.22.22 newman@6.2.3 newman-reporter-htmlextra@1.23.1 jest@30.5.2 storybook@10.6.3 jest-junit@17.0.0 pyright@1.1.414 pyright-to-gitlab-ci@0.1.3 cloc@2.10.0-cloc \
  && npm cache clean --force

# GO

# checkov:skip=CKV_DOCKER_8:Ensure the last USER is not root
# hadolint ignore=DL3002
USER root

# renovate: datasource=golang-version depName=go
ENV GO_VERSION=${GO_VERSION:-"1.27.3"}
ENV GO_FILENAME=go${GO_VERSION}.linux-amd64.tar.gz
ENV GO_URL=https://go.dev/dl/${GO_FILENAME}

RUN curl -fsSL -o /tmp/${GO_FILENAME} ${GO_URL} \
  && tar -C /usr/local -xzf /tmp/${GO_FILENAME} \
  && rm -rf /tmp/*

#USER ${USER}

ENV GOROOT=/usr/local/go
ENV GOPATH=${UBUNTU_USER_HOME}/go
ENV GO111MODULE=on

# tfsec is deprecated, use trivy config instead
RUN ${GOROOT}/bin/go install github.com/minamijoyo/tfupdate@v0.10.2 \
&& ${GOROOT}/bin/go install mvdan.cc/sh/v3/cmd/shfmt@v3.14.1 \
&& ${GOROOT}/bin/go install github.com/cweill/gotests/gotests@v1.9.0 \
&& ${GOROOT}/bin/go clean -cache -modcache

#RUN ls -lrta /home/ubuntu/.cache/go-build/
#RUN chown -R ${USER}:${GROUP} /home/ubuntu/go/ /home/ubuntu/.cache/

ENV PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}

# OPENJDK

# openjdk-21-jdk-headless is already provided by the selenium base image

# BUILDAH

# hadolint ignore=DL3008,SC1091,DL3006,DL4006
#RUN . /etc/os-release \
#  && apt-get update \
#  && apt-get -q -o Dpkg::Options::="--force-confnew" --no-install-recommends install -y \
#  ca-certificates curl gnupg2 && \
#  echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list && \
#  curl -fsL "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key" | apt-key add - && \
#  apt-get update \
#  && apt-get -q -o Dpkg::Options::="--force-confnew" --no-install-recommends install -y \
#  buildah \
#  && apt-get clean && rm -rf /var/lib/apt/lists/*

# TRIVY

# renovate: datasource=github-releases depName=aquasecurity/trivy
ENV TRIVY_VERSION=${TRIVY_VERSION:-"0.76.1"}
RUN curl -fsSL -o /tmp/html.tpl https://github.com/aquasecurity/trivy/raw/v${TRIVY_VERSION}/contrib/html.tpl \
  && curl -fsSL -o /tmp/gitlab-codequality.tpl https://github.com/aquasecurity/trivy/raw/v${TRIVY_VERSION}/contrib/gitlab-codequality.tpl
# hadolint ignore=DL3006,DL4006
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v${TRIVY_VERSION}

RUN mkdir -p /trivycache \
 && chown -R root. /trivycache \
 && find /trivycache -type d -exec chmod 755 '{}' \; \
 && find /trivycache -type f -exec chmod 644 '{}' \;

# CODE CLIMATE

#RUN curl -L https://github.com/codeclimate/codeclimate/archive/master.tar.gz | tar xvz && \
#  cd codeclimate-* && sudo make install

# CST

# RUN curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 && chmod +x container-structure-test-linux-amd64 && mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test
# renovate: datasource=github-releases depName=GoogleContainerTools/container-structure-test
ENV CST_VERSION=${CST_VERSION:-"1.22.1"}
RUN curl -fsSL -o /usr/local/bin/container-structure-test \
  https://github.com/GoogleContainerTools/container-structure-test/releases/download/v${CST_VERSION}/container-structure-test-linux-amd64 \
  && chmod +x /usr/local/bin/container-structure-test

# DIVE

# checkov:skip=CKV_DOCKER_9:Ensure that APT isn't used
# RUN curl -LO https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb && apt-get install --no-install-recommends -y ./dive_0.9.2_linux_amd64.deb && rm -f dive_0.9.2_linux_amd64.deb && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chown -R ${USER}:${GROUP} "${UBUNTU_USER_HOME}/.npm"

WORKDIR /tmp

#FROM prebuild as build

# checkov:skip=CKV_DOCKER_8:Ensure the last USER is not root
# hadolint ignore=DL3002
USER root

# RUN sed -i -e 's|^\[machine\]|#\[machine\]|g' /usr/share/containers/containers.conf

COPY modprobe.sh /usr/local/bin/modprobe
COPY dockerd-entrypoint.sh /usr/local/bin/

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

RUN chmod +x /usr/local/bin/dockerd-entrypoint.sh /usr/local/bin/modprobe

# RUN apt-get clean && rm -rf /var/lib/apt/lists/* && go clean -cache -modcache && rm -rf /home/ubuntu/.cache/ /home/ubuntu/go/pkg/mod/cache

# USER ${USER}

VOLUME /var/lib/docker

EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD ["/bin/bash"]

HEALTHCHECK NONE
