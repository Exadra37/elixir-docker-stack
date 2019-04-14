#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # EXECUTION
  ##############################################################################

    apt install -y --no-install-recommends \
      libcanberra-gtk3-module \
      firefox-esr
}

Main "${@}"
