#!/bin/sh

set -eu

Main()
{
  ################################################################################
  # IMPUT
  ################################################################################

    local home_dir="${1? Missing path to container home dir !!!}"
    local elixir_version="${2? Missing Elixir version!!!}"
    local docker_build_resources_dir="${3? Missing path to docker build resources dir !!!}"


  ################################################################################
  # VAR CONSTANTS
  ################################################################################

    local SUBLIME_PACKAGES_DIR="${home_dir}"/.config/sublime-text-3/Packages
    local SETUP_DIR="${docker_build_resources_dir}"/scripts/sublime-text-3/elixir/language-server-protocol


  ################################################################################
  # EXECUTION
  ################################################################################

    printf "\n>>> INSTALL ELIXIR LANGUAGE SERVER <<<\n"

    # from 1.7.0 assigns 1.7
    version="${elixir_version%.*}"

    if [ "${version}" \< "1.7" ]; then
      printf "\n---> WARNING: The Elixir Language Server requires a Elixir 1.7 or greater, and current version is ${elixir_version}. Skipping installation. \n"
      exit 0
    fi

    git clone https://github.com/tomv564/LSP.git "${SUBLIME_PACKAGES_DIR}"/LSP

    git clone https://github.com/JakeBecker/elixir-ls.git "${home_dir}"/elixir-ls
    #git clone https://github.com/elixir-lsp/elixir-ls.git "${home_dir}"/elixir-ls

    cd "${home_dir}"/elixir-ls
    mix deps.get
    MIX_ENV=prod mix elixir_ls.release -o rel

    mkdir -p "${home_dir}"/bin

    cp -v "${SETUP_DIR}"/bin/elixir-ls "${home_dir}"/bin/elixir-ls

    mkdir -p "${SUBLIME_PACKAGES_DIR}"/User

    cp -r "${SETUP_DIR}"/.config/sublime-text-3/Packages/User/LSP.sublime-settings "${SUBLIME_PACKAGES_DIR}"/User/LSP.sublime-settings
}

Main "${@}"
