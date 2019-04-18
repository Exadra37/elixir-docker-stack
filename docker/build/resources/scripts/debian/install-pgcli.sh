#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # EXECUTION
  ##############################################################################

      # python \
      # python-dev \
      # python-pip \
    apt install -y -q --no-install-recommends pgcli
}

Main
