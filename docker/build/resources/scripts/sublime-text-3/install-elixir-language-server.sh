#!/bin/sh

set -eu

Main()
{
  ################################################################################
  # IMPUT
  ################################################################################

    local home_dir="${1? Missing path to container home dir !!!}"


  ################################################################################
  # VAR CONSTANTS
  ################################################################################

    local SUBLIME_PACKAGES_DIR="${home_dir}"/.config/sublime-text-3/Packages


  ################################################################################
  # EXECUTION
  ################################################################################

    mkdir -p "${SUBLIME_PACKAGES_DIR}"

    git clone https://github.com/tomv564/LSP.git "${SUBLIME_PACKAGES_DIR}"/LSP

    git clone https://github.com/JakeBecker/elixir-ls.git "${home_dir}"/elixir-ls

    cd "${home_dir}"/elixir-ls
    mix deps.get
}

Main "${@}"
