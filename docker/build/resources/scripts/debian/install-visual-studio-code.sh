#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # CONSTANT VARS
  ##############################################################################

    local VSCODE_FILE="vsc.deb"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    # Install Visual Studio Code
    curl -L 'https://go.microsoft.com/fwlink/?LinkID=760868' -o "${VSCODE_FILE}"

    apt install -y --no-install-recommends ./"${VSCODE_FILE}" \
      apt-transport-https \
      libasound2 \
      libcanberra-gtk-module \
      libgconf-2-4 \
      libasound2 \
      libgtk2.0-0 \
      libxss1

    apt update
    apt install -y code

    # Force installation of missing dependencies for Visual Studio Code
    apt -y -f install
}

Main
