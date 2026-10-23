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

Switch to docker/ubuntu24/Dockerfile (image 2.1.0)

### Added
- GitHub Actions CI: ansible-lint, hadolint, image build, container-structure-test, Trivy scan
- Renovate tracking for pre-commit hooks and Dockerfile tool versions
- gitleaks and shellcheck pre-commit hooks
### Updated
- Python 3.14, ansible-core 2.21, ansible-lint 26
- selenium/standalone-chrome 4.51, Docker 29.9, Node 24, Go 1.27, Trivy 0.76
- Galaxy roles pinned to a tag or a commit sha
- Playbooks fixed with `ansible-lint --fix` (FQCN, YAML)
- Image npm tools: npm 12, newman 6, jest 30, storybook 10, jest-junit 17, pyright 1.1.414
- playbooks/python.yml: a single /opt/ansible/env python 3.12 virtualenv for Ubuntu 22.04/24.04 and RHEL 8/9,
  installed from requirements-current.txt (compiled from requirements-current.in)
### Remove
- docker/ubuntu16 to ubuntu20, Jenkinsfile, .travis.yml, tox.ini, package.json
- PHP/Apache/Composer, s6-overlay, Nomad, tfsec and dockerfile_lint from the image
- Python 2.7 to 3.8 virtualenvs and their requirements-current-*.txt files

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

`docker run -it -u 1004:999 -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /var/run/docker.sock:/var/run/docker.sock --entrypoint /bin/bash registry.albandrieu.com/fusion-risk/ansible-jenkins-slave:1.0.0`
