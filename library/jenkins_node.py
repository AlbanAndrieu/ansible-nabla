#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Create or configure Jenkins node via REST API
# see https://support.cloudbees.com/hc/en-us/articles/115003896171-Creating-node-with-the-REST-API for docs
import json
import platform

import requests
from ansible.module_utils.basic import AnsibleModule


def get_system_ca_bundle():
    dist_name = platform.linux_distribution()[0].lower()
    if 'centos' in dist_name or 'red hat' in dist_name:
        return '/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem'
    if 'ubuntu' in dist_name:
        return '/etc/ssl/certs/ca-certificates.crt'
    return None


def delete_jenkins_node(params, verify=None):
    url_delete = 'https://{}/computer/{}/doDelete'.format(
        params['x_jenkins_server'],
        params['hostname'],
    )
    auth = (
        params['x_auth']['username'],
        params['x_auth']['password'],
    )
    headers = {
        'Jenkins-Crumb': params['x_token'],
        'Content-Type':  'application/x-www-form-urlencoded',
    }
    response = requests.post(
        url_delete,
        auth=auth,
        headers=headers,
        verify=verify,
    )
    return response


def configure_jenkins_node(params, verify=None):
    url_create_new = 'https://{}/computer/doCreateItem'.format(
        params['x_jenkins_server'],
    )
    url_update = 'https://{}/computer/{}/configSubmit'.format(
        params['x_jenkins_server'],
        params['hostname'],
    )
    https_params = {
        'name': params['hostname'],
        'type': params['type'],
    }
    auth = (
        params['x_auth']['username'],
        params['x_auth']['password'],
    )
    headers = {
        'Jenkins-Crumb': params['x_token'],
        'Content-Type':  'application/x-www-form-urlencoded',
    }
    labelString = ' '.join(params['labels'])
    configuration = {
        '':                  [
            'hudson.plugins.sshslaves.SSHLauncher',
            'hudson.slaves.RetentionStrategy$Always',
        ],
        'labelString':       labelString,
        'launcher':          {
            '':                               '3',
            '$class':                         'hudson.plugins.sshslaves.SSHLauncher',
            'credentialsId':                  params['credentialsId'],
            'host':                           params['hostname'],
            'javaPath':                       '',
            'jvmOptions':                     '',
            'launchTimeoutSeconds':           '',
            'maxNumRetries':                  '',
            'port':                           params['port'],
            'prefixStartSlaveCmd':            '',
            'retryWaitTime':                  '',
            'sshHostKeyVerificationStrategy': {
                '$class':        'hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy',
                'stapler-class': 'hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy',
            },
            'stapler-class':                  'hudson.plugins.sshslaves.SSHLauncher',
            'suffixStartSlaveCmd':            '',
        },
        'mode':              'NORMAL',
        'name':              params['hostname'],
        'nodeDescription':   params['nodeDescription'],
        'nodeProperties':    {
            'stapler-class-bag': 'true',
        },
        'numExecutors':      params['numExecutors'],
        'remoteFS':          params['remoteFS'],
        'retentionStrategy': {
            '$class':        'hudson.slaves.RetentionStrategy$Always',
            'stapler-class': 'hudson.slaves.RetentionStrategy$Always',
        },
        'type':              params['type'],
    }
    # this configuration part is created separately, because we do not want to add
    # environment in node configuration, if there are no env vars or no tools at all
    if params['env'] != []:
        configuration['nodeProperties']['hudson-slaves-EnvironmentVariablesNodeProperty'] = {
            'env': params['env'],
        }
    if params['tools'] != []:
        configuration['nodeProperties']['hudson-tools-ToolLocationNodeProperty'] = {
            'locations': params['tools'],
        }
    data = 'json={}'.format(json.dumps(configuration))
    exists = requests.get(
        url_update,
        auth=auth,
        headers=headers,
        verify=verify,
    )
    if exists.status_code == 404:
        url = url_create_new
    else:
        url, params = url_update, None
    response = requests.post(
        url,
        data=data,
        params=https_params,
        auth=auth,
        headers=headers,
        verify=verify,
    )
    return response


def main():
    module = AnsibleModule(
        argument_spec={
            'hostname':         {
                'type':     'str',
                'required': True,

            },
            'state':            {
                'default': 'present',
                'choices': [
                    'present',
                    'absent',
                ],
            },
            'credentialsId':    {
                'type':    'str',
                'default': 'jenkins',  # jenkins@unix-slaves

            },
            'nodeDescription':  {
                'type':    'str',
                'default': 'Jenkins node automatically created by Ansible',

            },
            'labels':           {
                'type':    'list',
                'default': list(),

            },
            'env':              {
                # list of dicts in {key, value} format, for example:
                # - key: ARCH
                #   value: x86Linux
                'type':    'list',
                'default': list(),

            },
            'tools':            {
                # list of dicts in {key, home} format, for example:
                # - key: "hudson.plugins.git.GitTool$DescriptorImpl@git-system"
                #   home: "usr/bin/git"
                'type':    'list',
                'default': list(),

            },
            'remoteFS':         {
                'type':    'str',
                'default': '/home/jenkins',

            },
            'numExecutors':     {
                'type':    'int',
                'default': 1,

            },
            'type':             {
                'type':    'str',
                'default': 'hudson.slaves.DumbSlave',

            },
            'port':             {
                'type':    'int',
                'default': 22,

            },
            'x_jenkins_server': {
                'type':    'str',
                'default': 'localhost/jenkins',

            },
            'x_auth':           {
                'type':     'dict',
                'required': True,  # username, password
            },
            'x_token':          {
                'type':     'str',
                'required': True,

            },
        },
    )
    ca_bundle = get_system_ca_bundle()
    if ca_bundle is None:
        module.fail_json(
            msg='Unsupported Linux distribution, use CentOS7 or Ubuntu16',
        )
    if module.params['state'] == 'absent':
        delete_request = delete_jenkins_node(
            module.params,
            verify=ca_bundle,
        )
        if delete_request.status_code == 200:
            module.exit_json(
                changed=True,
                msg='Removed Jenkins node {}'.format(module.params['hostname']),
            )
        if delete_request.status_code == 404:
            module.exit_json(
                changed=False,
                msg='Jenkins node does not exist {}'.format(
                    module.params['hostname'],
                ),
            )
        module.fail_json(
            changed=False,
            msg='Unchecked exception during node deletion: {} {}'.format(
                delete_request.status_code,
                delete_request.text,
            ),
        )
    if module.params['state'] == 'present':
        configure_request = configure_jenkins_node(
            module.params,
            verify=ca_bundle,
        )
        if configure_request.status_code == 403:
            module.fail_json(
                changed=False,
                msg='Authentication failed, either token is invalid or user does not have permissions to create new node. Error message: {}'.format(
                    configure_request.text,
                ),
            )
        if configure_request.status_code != 200:
            module.fail_json(
                changed=False,
                msg='Unchecked exception during node configuration: {} {}'.format(
                    configure_request.status_code,
                    configure_request.text,
                ),
            )
        module.exit_json(
            changed=True,
            msg='Configured Jenkins node {}'.format(module.params['hostname']),
        )


if __name__ == '__main__':
    main()
