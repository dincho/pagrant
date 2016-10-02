#!/usr/bin/env bash
# https://gist.github.com/gretel/34008d667a8a243a9682e5207619ad95
# 2016 tom hensel <github@jitter.eu>
# `vagrant` on `ubuntu-16.04` can get in conflict with *unattended-upgrade* running and locking the `dpkg` subsystem. this script waits gracefully
# in `Vagrantfile`:
#  config.vm.provision 'Wait for unattended-upgrades', type: 'shell', path: './provisioning/wait_unattended_upgrades.sh', args: %w( dpkg apt unattended-upgrade )
#

function wait_procnames {
    while true; do
        alive_pids=()
        for pname in "$@"; do
            if [ "$(pgrep "$pname")" ]; then
                alive_pids+=("$pname ")
            fi
        done
        if [ "${#alive_pids[@]}" -eq 0 ]; then
            break
        else
            printf "waiting for: %s\n" "${alive_pids[@]}"
        fi
        sleep 1
    done
}

wait_procnames "$@"
