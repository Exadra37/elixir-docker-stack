#!/bin/sh

set -eu

Create_Env_File_If_Not_Exists()
{
  ############################################################################
  # INPUT
  ############################################################################

    local suffix="${1:-.docker-container}"

    local example_suffix="${2:--example}"


  ############################################################################
  # EXECUTION
  ############################################################################

    # Useful to pass environment variables into the container.
    if [ ! -f .env"${suffix}" ]; then
      if [ -f .env"${suffix}${example_suffix}" ]; then
        cp .env"${suffix}${example_suffix}" .env"${suffix}"
      else
        touch .env"${suffix}"
      fi
    fi
}
