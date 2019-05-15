#!/bin/sh

set -eu

# One Liner for testing in shell:
#   → if sudo -h > /dev/null 2>&1 ; then echo 'Sudo is enabled.' ; else echo 'Sudo is not enabled' ; fi
Sudo_Exists()
{
  ############################################################################
  # EXECUTION
  ############################################################################

    if sudo -h > /dev/null 2>&1; then
      # sudo exists
      return 0
    fi

    # sudo doesn't exist
    return 1
}

Sudo_Prefix()
{
  ############################################################################
  # EXECUTION
  ############################################################################

    if Sudo_Exists; then
      echo 'sudo'
      return
    fi

    echo ""
}
