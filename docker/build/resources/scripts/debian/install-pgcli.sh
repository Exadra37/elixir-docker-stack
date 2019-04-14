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
    apt install -y --no-install-recommends pgcli
}

Main
