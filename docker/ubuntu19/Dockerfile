# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
# Multistage build is not possible with Jenkins Docker Pipeline Plugin
FROM ubuntu:19.10
#FROM selenium/standalone-chrome:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG JENKINS_USER_HOME=${JENKINS_USER_HOME:-/home/jenkins}

# dockerfile_lint - ignore
LABEL name="ansible-jenkins-slave" version="1.9.0"
LABEL description="Image used by fusion-risk products to build Java/Javascript and CPP\
 this image is running on Ubuntu 19.10."
LABEL com.example.vendor="ACME Incorporated"

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

#Below HOME is needed to override seluser (selenium user)
ENV HOME=${JENKINS_USER_HOME}
ENV JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"

ENV CHROME_BIN=/usr/bin/google-chrome
ENV CHROMIUM_BIN=/usr/bin/chromium-browser

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM="xterm-256color"

USER root

#RUN echo "Acquire::http::Proxy \"${http_proxy}\";" > /etc/apt/apt.conf.d/proxy.conf

# Install ansible
# hadolint ignore=DL3008
RUN apt-get -q update &&\
    apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
    git bzip2 zip unzip python-yaml python-jinja2 python-pip rsyslog gpg-agent \
    ocl-icd-libopencl1 ocl-icd-opencl-dev clinfo numactl libnuma1 pciutils \
    apt-utils apt-transport-https ca-certificates software-properties-common \
    locales xz-utils ksh wget tzdata sudo curl lsof sshpass \
    systemd systemd-cron \
    python3-setuptools python3 python3-pip python3-dev python3-apt \
    python-lxml python3-lxml \
    openjdk-8-jdk maven gcc g++ make \
    net-tools iputils-ping x11-apps \
    gnome-keyring gnome-keyring gnupg2 pass \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove unnecessary getty and udev targets that result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

ENV TZ "Europe/Paris"
RUN echo "${TZ}" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && locale-gen en_US.UTF-8
#RUN dpkg-reconfigure --frontend noninteractive tzdata \

### PYTHON

RUN python3 -m pip install --upgrade pip==20.2.4 \
    && pip3 install ansible==2.10.3 zabbix-api==0.5.4 docker-compose==1.25.5

### DOCKER

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
# Install Docker from Docker Inc. repositories.
#RUN apt-get update -qq && apt-get install --no-install-recommends -qqy docker-ce=5:19.03.3~3-0~ubuntu-disco docker-ce-cli=5:19.03.3~3-0~ubuntu-disco && apt-get clean && rm -rf /var/lib/apt/lists/*

### JAVASCRIPT

# hadolint ignore=DL3008,DL3015
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && apt-get install -y nodejs=8.10.0~dfsg-2ubuntu0.4 npm=3.5.2-0ubuntu4 && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    npm set progress=false && \
    npm config set depth 0;
RUN npm install -g npm@6.14.4 && apt-get purge -y npm && ln -s /usr/local/bin/npm /usr/bin/npm
RUN npm -v && command -v npm # 6.7.0
RUN npm install -g bower@1.8.8 grunt@1.0.4 grunt-cli@1.3.2 webdriver-manager@12.1.7 yarn@1.19.1 yo@3.1.1
RUN npm install -g shrinkwrap@0.4.0 newman@4.5.5 xunit-viewer@5.1.11 json2csv@4.3.3 phantomas@1.20.1 dockerfile_lint@0.3.3
RUN npm install -g npm@6.10.3

ARG USER=${USER:-jenkins}
ARG GROUP=${GROUP:-docker}
ARG UID=${UID:-2000}
ARG GID=${GID:-2000}
# hadolint ignore=SC2059
RUN printf "\033[1;32mFROM UID:GID: ${UID}:${GID}- JENKINS_USER_HOME: ${JENKINS_USER_HOME} \033[0m\n" && \
    printf "\033[1;32mWITH user: $USER\ngroup: $GROUP \033[0m\n"

RUN printenv DBUS_SESSION_BUS_ADDRESS || true

RUN groupmod -g ${GID} docker
#RUN cat /etc/group | grep docker || true
#RUN id docker
#RUN getent passwd 2000 || true

# Add user jenkins to the image
#RUN groupadd -g ${GID} docker && \
RUN adduser --quiet --uid ${UID} --gid ${GID} --home ${JENKINS_USER_HOME} jenkins
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins1234" | chpasswd
RUN usermod -a -G docker jenkins

# Add the jenkins user to sudoers
RUN echo "jenkins    ALL=(ALL)    ALL" >> /etc/sudoers

# hadolint ignore=SC2059
RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

### ANSIBLE

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts
ENV ANSIBLE_CONFIG=${JENKINS_USER_HOME}/ansible.cfg

ARG ANSIBLE_VAULT_PASS
ENV ANSIBLE_VAULT_PASS=${ANSIBLE_VAULT_PASS:-"todo"}
RUN echo "${ANSIBLE_VAULT_PASS}" > $JENKINS_USER_HOME/vault.passwd && cat $JENKINS_USER_HOME/vault.passwd
COPY ansible.cfg *.yml playbooks/ansible.pub.key $JENKINS_USER_HOME/
COPY inventory $JENKINS_USER_HOME/inventory
COPY playbooks $JENKINS_USER_HOME/playbooks
COPY roles $JENKINS_USER_HOME/roles
COPY .ssh $JENKINS_USER_HOME/.ssh
#COPY package.json $JENKINS_USER_HOME/
# hadolint ignore=SC2046
RUN chown jenkins:$(id -gn jenkins) $JENKINS_USER_HOME $JENKINS_USER_HOME/.*

# Execute
#python36,brew are adding 2.7 G to the images

# hadolint ignore=DL3008,DL3015
RUN ansible-galaxy install -r "$JENKINS_USER_HOME/requirements.yml" -p "$JENKINS_USER_HOME/roles/" --ignore-errors && \
 ansible-playbook "$JENKINS_USER_HOME/playbooks/jenkins-full.yml" -i "$JENKINS_USER_HOME/inventory/hosts" -c local \
 -e "jenkins_ssh_key_file={{ jenkins_home }}/.ssh/id_rsa" -e "workspace=/tmp" \
 -e "jenkins_jdk8_enable=true" \
# -e "jdk_home=/usr/lib/jvm/java-8-openjdk-amd64/" \
 -e "jenkins_id=${UID}" -e "docker_gid=${GID}" \
 -e "nis_enabled=false" -e "automount_enabled=false" -e "dns_enabled=false" \
 --skip-tags=restart,vm,python35,python36,objc \
 --vault-id $JENKINS_USER_HOME/vault.passwd \
 -vvvv \
 && apt-get autoremove -y && apt-get clean && apt-get remove asciidoc -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/man/* /var/log/* "$HOME/roles" "$HOME/vault.passwd" "$HOME/ansible.log" \
# && rm -Rf $JENKINS_USER_HOME/playbooks/.node_cache/ \
# && rm -Rf $JENKINS_USER_HOME/.cpan $JENKINS_USER_HOME/.ansible \
# && rm -Rf $JENKINS_USER_HOME/.npm $JENKINS_USER_HOME/.node_cache $JENKINS_USER_HOME/.cache/pip \
 && chown -R "jenkins:$(id -gn jenkins)" "$HOME" && chmod -R 777 "${HOME}"

#/usr/bin/python3.7 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pip==20.2.4 \
    && pip install docker-compose==1.25.5 pre-commit==2.9.0 ansible-lint-junit==0.15

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN ifconfig | awk '/inet addr/{print substr($2,6)}' ## Display IP address (optional)

### HELM

ENV HELM_VERSION=${HELM_VERSION:-"v3.4.0"}
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_URL=https://get.helm.sh/${HELM_FILENAME}

# Kubernetes tools
# hadolint ignore=DL3020
#ADD ${HELM_URL} /tmp/${HELM_FILENAME}
RUN curl -L -o /tmp/${HELM_FILENAME} ${HELM_URL} \
  && tar -zxvf /tmp/${HELM_FILENAME} -C /tmp \
  && chmod +x /tmp/linux-amd64/helm \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp/*

#RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

ENV KUBECTL_VERSION=${KUBECTL_VERSION:-"v1.18.3"}
ENV KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

# hadolint ignore=DL3020
#ADD ${KUBECTL_URL} /tmp/kubectl
RUN curl -L -o /tmp/kubectl ${KUBECTL_URL} \
  && chmod +x /tmp/kubectl \
  && mv /tmp/kubectl /bin/kubectl \
  && rm -rf /tmp/*

ENV SKAFFOLD_URL=https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64

#ADD https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 skaffold
RUN curl -L -o /tmp/skaffold ${SKAFFOLD_URL} \
  && chmod +x /tmp/skaffold && mv /tmp/skaffold /usr/local/bin \
  && skaffold version \
  && rm -rf /tmp/*

### DRAFT

ENV DRAFT_VERSION v0.16.0
ENV DRAFT_FILENAME draft-${DRAFT_VERSION}-linux-amd64.tar.gz
ENV DRAFT_URL https://azuredraft.blob.core.windows.net/draft/${DRAFT_FILENAME}


COPY wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker
#VOLUME /var/lib/docker

# place the jenkins slave startup script into the container
#ADD jenkins-slave-startup.sh /
COPY entrypoint.sh /
#RUN chmod +x /jenkins-slave-startup.sh /entrypoint.sh && rm -fr /sbin/initctl && ln -s /jenkins-slave-startup.sh /sbin/initctl
RUN chmod +x /entrypoint.sh && rm -fr /sbin/initctl && ln -s /entrypoint.sh /sbin/initctl

ARG AGENT_VERSION=${AGENT_VERSION:-"4.3"}
ARG AGENT_WORKDIR=${JENKINS_USER_HOME}/agent

RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${AGENT_VERSION}/remoting-${AGENT_VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

COPY jenkins-agent.sh /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir ${JENKINS_USER_HOME}/.jenkins && mkdir -p ${AGENT_WORKDIR}

# hadolint ignore=SC2046
RUN chown -R jenkins:$(id -gn jenkins) $HOME $HOME/.*

# drop back to the regular jenkins user - good practice
USER jenkins
RUN mkdir ${HOME}/workspace && mkdir -p ${HOME}/.m2/repository && chmod 777 ${HOME}/ansible.log && chmod -R 777 ${HOME}/.cache || true
#RUN id jenkins && mkdir ${HOME}/.local && ls -lrtai $HOME/ && ls -lrtai $HOME/.sonar

RUN helm plugin install https://github.com/chartmuseum/helm-push.git

RUN chmod 700 ${HOME}/.ssh && chmod 600 ${HOME}/.ssh/id_rsa* && chmod 644 ${HOME}/.ssh/authorized_keys ${HOME}/.ssh/known_hosts || true

#BELOW npm install is adding 700Mb to the images
#RUN npm install --only=production && npm run update-webdriver

# Will create $JENKINS_USER_HOME/.local/share/applications/mimeapps.list
RUN google-chrome --version

# Working dir
WORKDIR $JENKINS_USER_HOME

EXPOSE 80

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
