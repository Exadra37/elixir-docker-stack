#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # EXECUTION
  ##############################################################################

    local hostname_with_ip_address="$(hostname -s)@$(hostname -i)"

    if [ "${1}" = "--quiet" ]; then
      echo ${hostname_with_ip_address}
    else
      printf "\n\n>>> OBSERVER REMOTE SHELL ADDRESS: ${hostname_with_ip_address}"
    fi

}

Main "${@}"
