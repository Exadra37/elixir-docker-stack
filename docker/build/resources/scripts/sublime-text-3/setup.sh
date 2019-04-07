#!/bin/sh

set -eu

Main()
{
  ################################################################################
  # INPUT
  ################################################################################

    local home_dir="${1? Missing home dir !!!}"
    local docker_build_resources_dir="${2? Missing path to docker build resources dir !!!}"


  ################################################################################
  # VAR CONSTANTS
  ################################################################################

    local SUBLIME_PACKAGES_DIR="${home_dir}"/.config/sublime-text-3/Packages
    local SCRIPT_DIR="${docker_build_resources_dir}"/scripts/sublime-text-3


  ################################################################################
  # EXECUTION
  ################################################################################

    mkdir -p "${home_dir}"/bin

    cp -v "${SCRIPT_DIR}"/bin/elixir-ls "${home_dir}"/bin/elixir-ls

    mkdir -p "${SUBLIME_PACKAGES_DIR}"/User

    cp -r "${SCRIPT_DIR}"/.config/sublime-text-3/Packages/User "${SUBLIME_PACKAGES_DIR}"
}

Main "${@}"
