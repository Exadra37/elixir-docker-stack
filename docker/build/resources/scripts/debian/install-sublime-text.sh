#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local user_name=${1? Missing user name !!!}
    local sublime_build=${2:-latest}


  ##############################################################################
  # CONSTANT VARS
  ##############################################################################

    local SUBLIME_CONFIG_DIR="/home/${user_name}/.config/sublime-text-3"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n>>>>>>>>>> INSTALLING SUBLIME FOR USER: ${user_name} <<<<<<<<<<\n"

    if [ -z "${sublime_build}" ]; then
      printf "\n---> SUBLIME BUILD IS INVALID \n"
      exit 1
    fi

    if [ "${sublime_build}" = "latest" ]; then

      printf "\n---> APT will be used to install Sublime for build: ${sublime_build} \n"

      apt install -y apt-transport-https

      wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -

      echo "deb https://download.sublimetext.com/ apt/stable/" > /etc/apt/sources.list.d/sublime-text.list

      apt update

      apt install -y sublime-text

      exit 0
    fi

    if [ -n "${sublime_build}" ]; then

      printf "\n---> DPKG will be used to install Sublime for build: ${sublime_build} \n"

      curl -O https://download.sublimetext.com/sublime-text_build-"${sublime_build}"_amd64.deb

      dpkg -i sublime-text_build-"${sublime_build}"_amd64.deb

      apt install -y -f

      # Create default dirs in User home directory necessary for Sublime
      su "${user_name}" -c "sh -c 'mkdir -p /home/${user_name}/.local/share'"
      su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}Cache'"
      su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}Local'"
      su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}Index'"
      su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}Packages'"
      su "${user_name}" -c "sh -c 'mkdir -p ${SUBLIME_CONFIG_DIR}Installed\ Packages'"

      exit 0
    fi
}

Main "${@}"
