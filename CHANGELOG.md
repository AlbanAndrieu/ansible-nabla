# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# Table of contents

<!-- toc -->

- [[Unreleased]](#unreleased)
- [[1.0.0] - 2020-01-21](#100---2020-01-21)
  * [Added](#added)
  * [Updated](#updated)
  * [Remove](#remove)

<!-- tocstop -->

## [Unreleased]

## [1.0.0] - 2020-01-21

Switch to docker/ubuntu18/Dockerfile

### Added
- kubernetes 1.17.2
- helm 2.16.1
- Docker linter : [hadolint](https://github.com/hadolint/hadolint), [dockerfilelint](https://hub.docker.com/r/replicated/dockerfilelint/), [dive](https://github.com/wagoodman/dive)
### Updated
- Image reduced to 3.5GB
- java updated to openjdk version "1.8.0_232"
- docker version 19.03.5
- node 11.15.0
- npm 6.13.6
- python3 default is Python 3.6.9
### Remove
- Python 35 will no more be supported
`skip-tags=python35,python37,objc`

`docker run -it -u 1004:999 -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /var/run/docker.sock:/var/run/docker.sock --entrypoint /bin/bash registry.misys.global.ad/fusion-risk/ansible-jenkins-slave:1.0.0`
