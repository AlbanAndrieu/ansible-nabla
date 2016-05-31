Java Keystore Certificate import
=========

Simple import into Java Keystore by connecting to the host and downloading the certificate. Should work with https, smtp or ldap certificates.

Requirements
------------

Java installed.

Role Variables
--------------

```
java_certificate_host: example.com
java_certificate_port: 443
java_certificate_alias: '{{java_certificate_host}}'
java_certificate_ca_path: /usr/lib/jvm/default-java/jre/lib/security/cacerts
java_certificate_store_pass: changeit
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: servers
  roles:
    - role: zealot128.java-certificate
      java_certificate_host: mail.example.com
      java_certificate_port: 465

    - role: zealot128.java-certificate
      java_certificate_host: www.example.com
      java_certificate_port: 443

    - role: zealot128.java-certificate
      java_certificate_host: ldap.example.com
      java_certificate_port: 636
```

License
-------

BSD

