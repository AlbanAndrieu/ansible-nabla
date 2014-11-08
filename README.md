## NABLA Deployment

- Requires Ansible 1.6.3 or newer
- Expects Ubuntu or CentOS/RHEL 6.x hosts

These playbooks deploy a very basic workstation with all the required tool needed for a developper or buildmaster or devops to work on NABLA.
Goal of this project is to integrate of several roles done by the community. 
Goal is to contribuate to the community as much as possible instead of creating a new role.
Goal is to ensure following roles (GIT submodules) to work in harmony.

Then run the playbook, like this:

	ansible-playbook -i hosts -c local -v workstation.yml -vvvv
	or
	setup.sh

When the playbook run completes, you should be able to work on any NABLA project, on the target machines.

This is a very simple playbook and could serve as a starting point for more complex projects. 

### Ideas for Improvement

Here are some ideas for ways that these playbooks could be extended:

- Write a playbook to deploy an NABLA application into the server.

We would love to see contributions and improvements, so please fork this
repository and send us your changes via pull requests.
