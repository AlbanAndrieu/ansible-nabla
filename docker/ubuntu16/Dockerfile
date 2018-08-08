# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM ubuntu:16.04

MAINTAINER Alban Andrieu "https://github.com/AlbanAndrieu"

LABEL vendor="NABLA" version="1.1"
LABEL description="Image used by Nabla products to build Java/Javascript and CPP\
 this image is running on Ubuntu 16.04."

ARG JENKINS_HOME=${JENKINS_HOME:-/home/jenkins}
ENV JENKINS_HOME=${JENKINS_HOME}

# Volume can be accessed outside of container
#VOLUME [${JENKINS_HOME}]

#ENV DEBIAN_FRONTEND noninteractive
ENV WORKDIR $JENKINS_HOME
#ENV ANSIBLE_LIBRARY /tmp/ansible/library
#ENV PYTHONPATH /tmp/ansible/lib:$PYTHON_PATH
#ENV PATH /tmp/ansible/bin:/sbin:/usr/sbin:/usr/bin:/bin:$PATH

# Add user jenkins to the image
#USER root
#RUN groupadd docker && adduser --quiet jenkins --home /home/jenkins && gpasswd -a jenkins docker
# Set password for the jenkins user (you may want to alter this).
#RUN echo jenkins:jenkins | chpasswd
RUN groupadd -g 1000 docker && \
    adduser --uid 1000 --gid 1000 --home /home/jenkins jenkins

# Working dir
#WORKDIR /home/jenkins
WORKDIR $JENKINS_HOME

ADD . $WORKDIR/

USER 0
#USER root

#COPY --chown=1000:0 . $JENKINS_HOME
COPY *.yml roles playbooks group_vars $JENKINS_HOME/

# Install ansible
ENV BUILD_PACKAGES="python-dev"
RUN apt-get clean && apt-get -y update && apt-get install -y $BUILD_PACKAGES git unzip python-yaml python-jinja2 python-pip openssh-server rsyslog && pip install ansible==2.4.1.0

# Execute
RUN ansible-galaxy install -r $JENKINS_HOME/requirements.yml -p $JENKINS_HOME/roles/ --ignore-errors && \
ansible-playbook $JENKINS_HOME/jenkins-slave-docker.yml -i $JENKINS_HOME/hosts -c local

# Install a basic SSH server
RUN mkdir -p /var/run/sshd

# Clean up APT when done.
#RUN AUTO_ADDED_PACKAGES=$(apt-mark showauto) \
#&& apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER 1000

# Standard SSH port
EXPOSE 22

#ENTRYPOINT  ["/etc/init.d/jenkins-swarm-client"]
#CMD ["/usr/sbin/sshd", "-D"]
CMD ["/bin/bash"]
#CMD ["-g", "deamon off;"]