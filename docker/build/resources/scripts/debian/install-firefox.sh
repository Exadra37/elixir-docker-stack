#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # EXECUTION
  ##############################################################################

    apt install -y -q --no-install-recommends \
      libcanberra-gtk3-module \
      firefox-esr
}

Main "${@}"
