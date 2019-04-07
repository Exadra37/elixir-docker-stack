#!/bin/sh

set -eu

Main()
{
  ################################################################################
  # INPUT
  ################################################################################

    local phoenix_install_from="${1? Missing from where to install the Phoenix Framework !!!}"


  ################################################################################
  # EXECUTION
  ################################################################################

    mix local.hex --force
    mix local.rebar --force
    mix archive.install --force ${phoenix_install_from}
}

Main "${@}"
