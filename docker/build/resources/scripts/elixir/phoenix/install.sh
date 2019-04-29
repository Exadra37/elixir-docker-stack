#!/bin/sh

set -eu

Main()
{
  ################################################################################
  # INPUT
  ################################################################################

    local phoenix_version="${1? Missing Phoenix version to install!!!}"

    local phoenix_install_from="hex phx_new ${phoenix_version}"

    # from 1.4.0 assigns 1.4
    local phoenix_major_version="${phoenix_version%.*}"

    # Phoenix framework installation procedure changed from 1.4 onwards.
    if [ "${phoenix_major_version}" \< "1.4" ]; then
      phoenix_install_from="https://github.com/phoenixframework/archives/raw/master/phx_new-${phoenix_version}.ez"
    fi

  ################################################################################
  # EXECUTION
  ################################################################################

    # installs the package manager
    mix local.hex --force

    # installs rebar and rebar3
    mix local.rebar --force

    ln -s "${HOME}"/.mix/rebar "${HOME}"/bin/rebar
    ln -s "${HOME}"/.mix/rebar3 "${HOME}"/bin/rebar3

    mix archive.install --force ${phoenix_install_from}
}

Main "${@}"
