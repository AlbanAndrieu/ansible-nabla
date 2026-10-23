###################
 Roles & Playbooks
###################

TODO - it should be the most exhaustive section.

These playbooks deploy a very basic workstation with all the required
tool needed for a developer or buildmaster to work on NABLA.

Then run the playbook, like this:

.. code::

   ansible-playbook -i hosts -c local -v workstation.yml -vvvv

When the playbook run completes, you should be able to work on any NABLA
project, on the target machines.

This is a very simple playbook and could serve as a starting point for
more complex projects.

**********
 Graphviz
**********

Generate graph:

.. code:: python

   pip install graphviz
   python3 ./docs/files/ansible-roles-dependencies.py

Files is:

.. literalinclude:: files/ansible-roles-dependencies.py
   :linenos:
   :language: python
   :emphasize-lines: 3, 10, 16, 22, 28 ,45-46

For playbook:

.. code:: python

   pip install ansible-playbook-grapher
   ansible-playbook-grapher --include-role-tasks  playbooks/jenkins-slave.yml  -s -v
   pip install ansible-inventory-grapher
   ansible-inventory-grapher -i inventory/production jenkins-slaves -d test --format "test-jenkins-slaves.dot"
   ansible-inventory-grapher -i inventory/production albandri.albandrieu.com  -d test --format "test-albandri.albandrieu.com.dot"

.. code:: bash

       dot -Tpng test.dot -o test.png
   dot -Tps jenkins-slave.dot -o jenkins-slave.ps
   dot -Tpng test-jenkins-slaves.dot -o test-jenkins-slaves.png
   dot -Tpng test-albandri.albandrieu.com.dot -o test-albandri.albandrieu.com.png

Output:

.. image:: files/test.png
   :width: 400pt

******************************
 Folder Structure Conventions
******************************

> Folder structure options and naming conventions for software projects

A typical top-level directory layout:

.. code:: none

   .
   ├── docs                    # Documentation files (alternatively `doc`)
   docker                      # Where to put image Dockerfile
   ├── scripts                 # Source files
   ├── inventory
   │   production
   ├── playbooks               # Ansible playbooks
   ├── roles                   # Ansible roles
   Dockerfile                  # A link to default Dockerfile to build (DockerHub)
   .github/workflows           # GitHub Actions CI (lint, image build, Trivy scan)
   .pre-commit-config.yaml
   Pipfile                     # Python packages (pipenv), locked in Pipfile.lock
   requirements.txt            # Python package used for production only
   requirements.yml            # Ansible requirements, will be add to roles directory
   sonar-project.properties    # Will run sonar standalone scan
   LICENSE
   CHANGELOG.md
   README.md
   └── target                  # Compiled files (alternatively `dist`) for maven

   docker directory is used only to build project
   .
   ├── ...
   ├── docker                  # Docker files used to build project
   │   └── ubuntu24
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

***********
 Use cases
***********

Minimal Jenkins Slave
=====================
