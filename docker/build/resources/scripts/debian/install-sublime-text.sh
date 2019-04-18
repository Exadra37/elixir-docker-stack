#!/bin/sh

set -eu

Install_Package_Control()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local user_name=${1? Missing user name to install sublime for!!!}


  ##############################################################################
  # CONSTANT VARS
  ##############################################################################

    local SUBLIME_CONFIG_DIR="/home/${user_name}/.config/sublime-text-3"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n---> INSTALL PACKAGE CONTROL FOR SUBLIME TEXT 3 \n"

    # Create default dirs in User home directory necessary for Sublime
    su "${user_name}" -c "sh -c 'mkdir -p /home/${user_name}/.local/share'"
    su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}/Cache'"
    su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}/Local'"
    su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}/Index'"
    su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}/Installed\ Packages'"
    su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}/Packages/User'"

    su "${user_name}" -c "sh -c 'curl -fsSL https://packagecontrol.io/Package%20Control.sublime-package -o ${SUBLIME_CONFIG_DIR}/Installed\ Packages/Package\ Control.sublime-package'"
}

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local sublime_build=${1:-latest}
    local user_name=${2? Missing user name!!!}
    local docker_build_resources_dir="${3? Missing path to docker build resources dir!!!}"


  ################################################################################
  # VAR CONSTANTS
  ################################################################################

    local SUBLIME_PACKAGES_DIR=/home/"${user_name}"/.config/sublime-text-3/Packages
    local SCRIPT_DIR="${docker_build_resources_dir}"/scripts/sublime-text-3/"${user_name}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n>>>>>>>>>> INSTALLING SUBLIME TEXT 3 FOR USER: ${user_name} <<<<<<<<<<\n"

    if [ -z "${sublime_build}" ]; then
      printf "\n---> SUBLIME BUILD IS INVALID \n"
      exit 1
    fi

    apt install -y --no-install-recommends \
      dbus-x11 \
      libcanberra-gtk3-module

    if [ "${sublime_build}" = "latest" ]; then

      printf "\n---> APT will be used to install Sublime for build: ${sublime_build} \n"

      apt install -y -q --no-install-recommends \
        apt-transport-https \
        ca-certificates

      curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg -o pgp.key
      apt-key add pgp.key
      rm -f pgp.key
      #apt-key adv --fetch-keys https://download.sublimetext.com/sublimehq-pub.gpg

      echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list

      apt update

      apt install -y --no-install-recommends sublime-text

    else

      printf "\n---> DPKG will be used to install Sublime for build: ${sublime_build} \n"

      curl -O https://download.sublimetext.com/sublime-text_build-"${sublime_build}"_amd64.deb

      dpkg -i sublime-text_build-"${sublime_build}"_amd64.deb

    fi

    Install_Package_Control "${user_name}"

    cp -r "${SCRIPT_DIR}"/.config/sublime-text-3/Packages/User "${SUBLIME_PACKAGES_DIR}"
}

Main "${@}"
