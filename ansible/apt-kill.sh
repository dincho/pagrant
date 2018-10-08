#!/usr/bin/env bash
# `vagrant` on `ubuntu-16.04` can get in conflict with *unattended-upgrade* running and locking the `dpkg` subsystem. this script stops the service
#  config.vm.provision 'Stop unattended-upgrades', type: 'shell', path: './ansible/apt-kill.sh'

systemctl stop apt-daily.service
systemctl is-active --quiet apt-daily.service && systemctl kill --kill-who=all apt-daily.service
exit 0
