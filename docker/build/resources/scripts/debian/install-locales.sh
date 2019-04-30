#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local localization=${1? Missing localization for Locales !!!}
    local encoding=${2? Missing encoding for Locales !!!}


  ##############################################################################
  # EXECUTION
  ##############################################################################

    apt install -y -q --no-install-recommends locales

    echo "${localization} ${encoding}" > /etc/locale.gen
    locale-gen "${encoding}"
}

Main "${@}"
