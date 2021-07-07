# NABLA Deployment

- Requires Ansible 2.5.0 or newer
- Expects Ubuntu or CentOS/RHEL 6.x hosts

These playbooks deploy a very basic workstation with all the required tool needed for a developper or buildmaster or devops to work on NABLA.
Goal of this project is to integrate of several roles done by the community.
Goal is to contribuate to the community as much as possible instead of creating a new role.
Goal is to ensure following roles (GIT submodules) to work in harmony.

Then run the playbook, like this:

	ansible-playbook -i hosts -c local -v nabla.yml -vvvv
	or
	export ANSIBLE_VAULT_PASS=todo
	./scripts/docker-build.sh

When the playbook run completes, you should be able to work on any NABLA project, on the target machines.

This is a very simple playbook and could serve as a starting point for more complex projects.

## How to run it

### Install python dependencies

```
#pip2.7 freeze > requirements.txt
sudo pip2.7 install -r requirements.txt
```

### Install ansible

```
sudo pip2 install ansible==2.4.1.0
```

### Quality tools

See [pre-commit](http://pre-commit.com/)
Run `pre-commit install`

Run `pre-commit run --all-files`

Run `SKIP=ansible-lint git commit -am 'Add key'`
Run `git commit -am 'Add key' --no-verify`

### Docker image

See [ansible-nabla](https://hub.docker.com/r/nabla/ansible-nabla/) or [ansible-jenkins-slave-docker](https://hub.docker.com/r/nabla/ansible-jenkins-slave-docker/)

#### Pull image
```
docker pull nabla/ansible-nabla:1.0.3
```
#### Start container
```
#Sample using container to buid my local workspace
docker run -t -d -w /sandbox/project-to-build -v /workspace/users/albandri30/:/sandbox/project-to-build:rw --name sandbox nabla/ansible-nabla:latest cat
#More advance sample using jenkins user on my workstation in order to get bash completion, git-radar and most of the dev tools I need
# -v/data1/home/albandri/.git-radar/:/home/jenkins/.git-radar/
docker run -it -u 1004:999 --rm --net=host --pid=host --dns-search=nabla.mobi --init -v /workspace:/workspace -v /jenkins:/home/jenkins -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/bash_completion.d:/etc/bash_completion.d:ro --name sandbox nabla/ansible-nabla:latest -s
#Now if I want to use my user albandri (1000) instead of jenkins
docker run -it -u 1000:999 --rm --net=host --pid=host --dns-search=nabla.mobi --init -w /sandbox/project-to-build -v /workspace/users/albandri30/:/sandbox/project-to-build:rw -v /workspace:/workspace -v /data1/home/albandri/:/home/jenkins -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /etc/bash_completion.d:/etc/bash_completion.d:ro --name sandbox nabla/ansible-nabla:latest /bin/bash

```
#### Build
```
docker exec sandbox /opt/maven/apache-maven-3.2.1/bin/mvn -B -Djava.io.tmpdir=./tmp -Dmaven.repo.local=/home/jenkins/.m2/.repository -Dmaven.test.failure.ignore=true -s /home/jenkins/.m2/settings.xml -f cmr/pom.xml clean install
```

#### Stop & remove container
```
docker stop sandbox
docker rm sandbox
```

### Build & development

Run `./scripts/run-ansible-workstation.sh` for building like Jenkins.
Run `./scripts/setup.sh` for building.
Run `./scripts/docker-build.sh` for building docker image.


## Folder Structure Conventions

> Folder structure options and naming conventions for software projects

### A typical top-level directory layout

    .
    ├── docs                    # Documentation files (alternatively `doc`)
    docker                      # Where to put image Dockerfile (link)
    ├── scripts                 # Source files
    ├── inventory
    │   production
    ├── playbooks               # Ansible playbooks
    ├── roles                   # Ansible roles
    bower.json                  # Bower not build directly, using maven instead
    Dockerfile                  # A link to default Dockerfile to build (DockerHub)
    Jenkinsfile
    package.json                # Nnpm not build directly, using maven instead
    pom.xml                     # Will run maven clean install
    .pre-commit-config.yaml
    requirements.testing.txt    # Python package used for test and build only
    requirements.txt            # Python package used for production only
    requirements.yml            # Ansible requirements, will be add to roles directory
    tox.ini
    sonar-project.properties    # Will run sonar standalone scan
    LICENSE
    CHANGELOG.md
    README.md
    └── target                  # Compiled files (alternatively `dist`) for maven

    docker directory is used only to build project
    .
    ├── ...
    ├── docker                  # Docker files used to build project
    │   ├── ubuntu18            # End-to-end, integration tests (alternatively `e2e`)
    │   └── ubuntu20
    │       Dockerfile          # File to build
    │       config.yaml         # File to run CST
    └── ...

    .
    ├── ...
    ├── docs                    # Documentation files
    │   ├── index.rst           # Table of contents
    │   ├── faq.rst             # Frequently asked questions
    │   ├── misc.rst            # Miscellaneous information
    │   ├── usage.rst           # Getting started guide
    │   └── ...                 # etc.
    └── ...

## Dependency Graph

### Ansigenome

See ansigenome.conf file in your HOME folder ~.ansigenome.conf and templates in misc/ansigenome/templates

### Python 3.8 graphviz

 * [graphviz](https://pypi.org/project/graphviz/)

```
pip install graphviz
python3 ./scripts/ansible-roles-dependencies.py
```

![Dependency Graph](roles/test.png)

## Update README.md


  * [github-markdown-toc](https://github.com/jonschlinkert/markdown-toc)
  * With [github-markdown-toc](https://github.com/Lucas-C/pre-commit-hooks-nodejs)

```
npm install --save markdown-toc
markdown-toc README.md
markdown-toc CHANGELOG.md  -i
```

```
git add README.md
pre-commit run markdown-toc
```

### Ideas for Improvement

Here are some ideas for ways that these playbooks could be extended:

- Test this playbooks on all aservers automatically.
- Write a playbook to deploy an NABLA application into the server.

We would love to see contributions and improvements, so please fork this
repository and send us your changes via pull requests.

## Update README.md


  * [github-markdown-toc](https://github.com/jonschlinkert/markdown-toc)
  * With [github-markdown-toc](https://github.com/Lucas-C/pre-commit-hooks-nodejs)

```
npm install --save markdown-toc
markdown-toc README.md
markdown-toc CHANGELOG.md  -i
```

```
git add README.md
pre-commit run markdown-toc
```
