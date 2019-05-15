#!/bin/sh

set -eu

Map_Erlang_Version_For_Erlang_Solutions()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local version="${1? Missing version to fix !!!}"

    local stack_build_source="${2? Missing build source for the stack  !!!}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    if [ "${stack_build_source}" = "esl" ]; then

      # extract all the dots on the erlang version:
      # `21.3.7.1` will give us `...`
      local version_dots="${version//[^.]}"

      # An erlang version like `21.3.7.1` doesn't need to be mapped, and we
      # know it based on matching the dots on it.
      if [ "${version_dots}" != "..." ]; then

        local version_map=$( grep "^erlang:${version}\.\.\." "${ELIXIR_DOCKER_STACK_INSTALL_DIR}"/docker/build/releases/map-docker-erlang-versions-to-erlang-esl-versions.txt )

        # If we we have a version map, it means the request Erlang version
        # needs to be correctly mapped for the one used by Erlang Solutions.
        # Version map example:
        #   * `erlang:21.3.7...esl:21.3.7.1`
        if [ -n "${version_map}" ]; then

          local version=${version_map##*:}

          # If we do not have a Erlang Solutions versions, then we have a
          # broken map.
          if [ -z "${version}" ]; then
            Print_Fatal_Error "Failed to retrieve Erlang Solutions version from: ${version_map}"
          fi

        fi
      fi
    fi

    echo -n ${version}
}

Map_Elixir_Version_For_Erlang_Solutions()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local version="${1? Missing version to fix !!!}"

    local stack_build_source="${2? Missing build source for the stack !!!}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    if [ "${stack_build_source}" = "esl" ]; then

      # extract all the dots and the dash form the elixir version:
      # `1.8.1-2` will give us `..-`
      local version_dots="${version//[^.-]}"

      # An elixir version like `1.8.1-2` doesn't need to be mapped, and we
      # know it based on matching the dots and the dash on it.
      if [ "${version_dots}" != "..-" ]; then

        local version_map=$( grep "^elixir:${version}\.\.\." "${ELIXIR_DOCKER_STACK_INSTALL_DIR}"/docker/build/releases/map-docker-elixir-versions-to-elixir-esl-versions.txt )

        # If we we have a version map, it means the requested Elixir version
        # needs to be correctly mapped for the one used by Erlang Solutions.
        # Version map example:
        #   * `elixir:1.8.1...esl:1.8.1-2`
        # https://packages.erlang-solutions.com/erlang/elixir/FLAVOUR_2_download/elixir_1.8.1-2~debian~stretch_amd64.deb
        if [ -n "${version_map}" ]; then

          local version=${version_map##*:}

          # If we do not have a Erlang Solutions versions, then we have a
          # broken map.
          if [ -z "${version}" ]; then
            Print_Fatal_Error "Failed to retrieve Erlang Solutions version from: ${version_map}"
          fi

        else

          # elixir version: `1.8.1` becomes `1.8.1-1`
          # https://packages.erlang-solutions.com/erlang/elixir/FLAVOUR_2_download/elixir_1.8.1-1~debian~stretch_amd64.deb
          local version="${version}-1"
        fi
      fi
    fi

    echo -n ${version}
}

Map_Version_For_Docker_Tag()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local version="${1? Missing version to map.}"

    local stack_name="${2? Missing the stack name.}"

    local stack_build_source="${2? Missing build source for the stack.}"


  ##############################################################################
  # VARS
  ##############################################################################

    local user_release_file="${ELIXIR_DOCKER_STACK_DATA_DIR}/${stack_name}/${stack_build_source}/${version}.txt"

    local stack_release_file="${ELIXIR_DOCKER_STACK_INSTALL_DIR}/${stack_name}/${stack_build_source}/${version}.txt"


  ##############################################################################
  # EXECUTION
  ##############################################################################


    if [ -f "${user_release_file}" ]; then

      local version="$( cat "${user_release_file}" )"

    elif [ -f "${stack_release_file}" ]; then

      local version="$( cat "${stack_release_file}" )"

    fi

    echo -n ${version}
}
