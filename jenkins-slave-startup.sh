#!/bin/bash
set -ex

#locale-gen en_US.UTF-8

# start the docker daemon
sudo /usr/local/bin/wrapdocker &

# start the ssh daemon
sudo /usr/sbin/sshd -D
# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"
