#!/bin/sh

set -eu

Build_Docker_Stack_Tag()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local stack_name="${1? Missing Docker stack to build !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    local phoenix_version="${3? Missing PhoBuild_Erlang_Docker_ImageBuild_Erlang_Docker_ImageBuild_Erlang_Docker_Imageenix version !!!}"

    local elixir_version="${4? Missing Elixir version !!!}"

    local erlang_otp_version="${5? Missing Erlang OTP version !!!}"

    local os_name="${6? Missing operating system name !!!}"

    local os_version="${7? Missing operating system version !!!}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    case "${stack_name}" in
      erlang )
        local image_tag="$( Build_Erlang_Tag ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"
      ;;

      elixir )
        local image_tag="$( Build_Elixir_Tag ${elixir_version} ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"
      ;;

      phoenix )
        local image_tag="$( Build_Phoenix_Tag ${phoenix_version} ${elixir_version} ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"
      ;;

      * )
        Print_Fatal_Error "Unknown Stack: ${stack_name}"
    esac

    echo -n "${image_tag}"
}

Build_Docker_Stack()
{
  Print_Text_With_Label "FUNCTION" "Build_Docker_Stack" "4"

  ##############################################################################
  # INPUT
  ##############################################################################

    local stack_name="${1? Missing Docker stack to build !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    local phoenix_version="${3? Missing Phoenix version !!!}"

    local elixir_version="${4? Missing Elixir version !!!}"

    local erlang_otp_version="${5? Missing Erlang OTP version !!!}"

    local os_name="${6? Missing operating system name !!!}"

    local os_version="${7? Missing operating system version !!!}"

    local is_local_docker_image="${8? Missing if is a local docker image !!!}"

    shift 8

    local build_options="${@}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    Print_Text_With_Label "STACK NAME" "${stack_name}" "2"

    case "${stack_name}" in

      erlang )

        Build_Erlang_Docker_Image \
          "${erlang_otp_version}" \
          "${stack_build_source}" \
          "${os_name}" \
          "${os_version}" \
          "${is_local_docker_image}" \
          ${build_options}

        return
      ;;

      elixir )

        Build_Elixir_Docker_Image \
          "${elixir_version}" \
          "${erlang_otp_version}" \
          "${stack_build_source}" \
          "${os_name}" \
          "${os_version}" \
          "${is_local_docker_image}" \
          ${build_options}

        return
      ;;

      phoenix )

        Build_Phoenix_Docker_Image \
          "${phoenix_version}" \
          "${elixir_version}" \
          "${erlang_otp_version}" \
          "${stack_build_source}" \
          "${os_name}" \
          "${os_version}" \
          "${is_local_docker_image}" \
          ${build_options}

        return
      ;;
    esac
}

Build_Erlang_Docker_Image()
{
  Print_Text_With_Label "FUNCTION" "Build_Erlang_Docker_Image" "4"

  ##############################################################################
  # INPUT
  ##############################################################################

    local erlang_otp_version="${1? Missing Erlang OTP version !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    local os_name="${3? Missing operating system name !!!}"

    local os_version="${4? Missing operating system version !!!}"

    local is_local_docker_image="${5? Missing if is a local docker image !!!}"

    shift 5

    local build_options="${@}"


  ##############################################################################
  # VARS
  ##############################################################################

    local build_args="--build-arg OS_TAG=${os_version}"
    local build_args="${build_args} --build-arg DOCKER_ERLANG_VERSION=${erlang_otp_version}"
    local build_args="${build_args} --build-arg DOCKER_REBAR3_VERSION=${EDS_REBAR3_VERSION}"
    local build_args="${build_args} --build-arg DOCKER_DOCSH_VERSION=${EDS_DOCSH_VERSION}"

    local image_tag="$( Build_Erlang_Tag ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    Build_Docker_Image \
      "erlang" \
      "${stack_build_source}" \
      "${image_tag}" \
      "${os_name}" \
      "${os_version}" \
      "${is_local_docker_image}" \
      "${build_args}" \
      ${build_options}
}

Build_Erlang_Tag()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local erlang_otp_version="${1? Missing Erlang version !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    #local os_name="${3? Missing operating system name !!!}"

    #local os_version="${4? Missing operating system version !!!}"


  ##############################################################################
  # VARS
  ##############################################################################

    #local stack_metadata="$( Build_Stack_Metadata ${stack_build_source} ${os_name} ${os_version} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    #echo "${erlang_otp_version}_${stack_metadata}"
    echo "${erlang_otp_version}_${stack_build_source}"
}

Build_Elixir_Docker_Image()
{
  Print_Text_With_Label "FUNCTION" "Build_Elixir_Docker_Image" "4"

  ##############################################################################
  # INPUT
  ##############################################################################

    local elixir_version="${1? Missing Elixir version !!!}"

    local erlang_otp_version="${2? Missing Erlang OTP version !!!}"

    local stack_build_source="${3? Missing the build source for the docker stack being built !!!}"

    local os_name="${4? Missing operating system name !!!}"

    local os_version="${5? Missing operating system version !!!}"

    local is_local_docker_image="${6? Missing if is a local docker image !!!}"

    shift 6

    local build_options="${@}"


  ##############################################################################
  # VARS
  ##############################################################################

    local eralng_tag="$( Build_Erlang_Tag ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"

    local build_args="--build-arg ERLANG_TAG=${eralng_tag}"
    local build_args="${build_args} --build-arg DOCKER_ELIXIR_VERSION=${elixir_version}"

    local image_tag="$( Build_Elixir_Tag ${elixir_version} ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    Build_Erlang_Docker_Image \
      "${erlang_otp_version}" \
      "${stack_build_source}" \
      "${os_name}" \
      "${os_version}" \
      "${is_local_docker_image}" \
      ${build_options}

    Build_Docker_Image \
      "elixir" \
      "${stack_build_source}" \
      "${image_tag}" \
      "${os_name}" \
      "${os_version}" \
      "${is_local_docker_image}" \
      "${build_args}" \
      ${build_options}
}

Build_Elixir_Tag()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local elixir_version="${1? Missing Elixir Version !!!}"

    local erlang_otp_version="${2? Missing Erlang version !!!}"

    local stack_build_source="${3? Missing the build source for the docker stack being built !!!}"

    #local os_name="${4? Missing operating system name !!!}"

    #local os_version="${5? Missing operating system version !!!}"


  ##############################################################################
  # VARS
  ##############################################################################

    #local stack_metadata="$( Build_Stack_Metadata ${stack_build_source} ${os_name} ${os_version} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    #echo "${elixir_version}_erlang-${erlang_otp_version}_${stack_metadata}"
    echo "${elixir_version}_erlang-${erlang_otp_version}_${stack_build_source}"
}

Build_Phoenix_Docker_Image()
{
  Print_Text_With_Label "FUNCTION" "Build_Phoenix_Docker_Image" "4"

  ##############################################################################
  # INPUT
  ##############################################################################

    local phoenix_version="${1? Missing Phoenix version !!!}"

    local elixir_version="${2? Missing Elixir version !!!}"

    local erlang_otp_version="${3? Missing Erlang OTP version !!!}"

    local stack_build_source="${4? Missing the build source for the docker stack being built !!!}"

    local os_name="${5? Missing operating system name !!!}"

    local os_version="${6? Missing operating system version !!!}"

    local is_local_docker_image="${7? Missing if is a local docker image !!!}"

    shift 7

    local build_options="${@}"


  ##############################################################################
  # VARS
  ##############################################################################

    local elixir_tag="$( Build_Elixir_Tag ${elixir_version} ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"

    local build_args="--build-arg ELIXIR_TAG=${elixir_tag}"
    local build_args="${build_args} --build-arg DOCKER_PHOENIX_VERSION=${phoenix_version}"

    local image_tag="$( Build_Phoenix_Tag ${phoenix_version} ${elixir_version} ${erlang_otp_version} ${stack_build_source} ${os_name} ${os_version} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    Build_Erlang_Docker_Image \
      "${erlang_otp_version}" \
      "${stack_build_source}" \
      "${os_name}" \
      "${os_version}" \
      "${is_local_docker_image}" \
      ${build_options}

    Build_Elixir_Docker_Image \
      "${elixir_version}" \
      "${erlang_otp_version}" \
      "${stack_build_source}" \
      "${os_name}" \
      "${os_version}" \
      "${is_local_docker_image}" \
      ${build_options}

    Build_Docker_Image \
      "phoenix" \
      "${stack_build_source}" \
      "${image_tag}" \
      "${os_name}" \
      "${os_version}" \
      "${is_local_docker_image}" \
      "${build_args}" \
      ${build_options}
}

Build_Phoenix_Tag()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local phoenix_version="${1? Missing Phoenix Version !!!}"

    local elixir_version="${2? Missing Elixir Version !!!}"

    local erlang_otp_version="${3? Missing Erlang OTP version !!!}"

    local stack_build_source="${4? Missing the build source for the docker stack being built !!!}"

    #local os_name="${5? Missing operating system name !!!}"

    #local os_version="${6? Missing operating system version !!!}"


  ##############################################################################
  # VARS
  ##############################################################################

    #local stack_metadata="$( Build_Stack_Metadata  ${stack_build_source} ${os_name} ${os_version} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    #echo "${phoenix_version}_elixir-${elixir_version}_erlang-${erlang_otp_version}_${stack_metadata}"
    echo "${phoenix_version}_elixir-${elixir_version}_erlang-${erlang_otp_version}_${stack_build_source}"
}

Build_Docker_Image()
{
  Print_Text_With_Label "FUNCTION" "Build_Docker_Image" "4"

  ##############################################################################
  # INPUT
  ##############################################################################

    local stack_name="${1? Missing Docker stack to build !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    local image_tag="${3? Missing docker image tag !!!}"

    local os_name="${4? Missing operating system name !!!}"

    local os_version="${5? Missing operating system version !!!}"

    local is_local_docker_image="${6? Missing if is a local docker image !!!}"

    local build_args="${7? Missing docker build arguments !!!}"

    shift 7

    local build_options="${@}"


  ##############################################################################
  # VARS
  ##############################################################################

    local extension="Dockerfile"

    if [ "${is_local_docker_image}" = "true" ]; then
      local extension="local.${extension}"
    fi

    local stack_metadata="$( Build_Stack_Metadata  ${stack_build_source} ${os_name} ${os_version} )"

    local dockerfile_path="${DOCKER_BUILD_PATH}/${stack_name}_${stack_metadata}.${extension}"

    local image_name="$( Build_Docker_Image_Name ${stack_name} )"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    Print_Text_With_Label "DOCKER IMAGE NAME" "${image_name}" "1"

    Print_Text_With_Label "DOCKER IMAGE TAG" "${image_tag}" "1"

    Print_Text_With_Label "DOCKERFILE PATH" "${dockerfile_path}" "2"

    Print_Text_With_Label "DOCKER BUILD OPTIONS" "${build_options}" "3"

    Print_Text_With_Label "DOCKER BUILD ARGS" "${build_args}" "3"

    ${SUDO_PREFIX} docker build \
      --no-cache \
      ${build_options} \
      ${build_args} \
      --file "${dockerfile_path}" \
      --tag "${image_name}:${image_tag}" \
      "${DOCKER_BUILD_PATH}"
}

Build_Stack_Metadata()
{
  ##############################################################################
  # INBuild_Docker_Image_NamePUT
  ##############################################################################

    local stack_build_source="${1? Missing the build source for the docker stack being built !!!}"

    local os_name="${2? Missing operating system name !!!}"

    local os_version="${3? Missing operating system version !!!}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    echo "${stack_build_source}_${os_name}-${os_version}"
}

Build_Docker_Image_Name()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local stack_name="${1? Missing Docker stack name !!!}"


  ##############################################################################
  # EXECUTIONBuild_Docker_Image_Name
  ##############################################################################

    echo "${VENDOR_NAME}"/"${stack_name}"-dev
}
