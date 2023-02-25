#!/bin/sh

set -eu

Start_Observer_Container()
{
  # to implement over ssh tunnel:
  #   * https://sgeos.github.io/elixir/erlang/observer/2016/09/16/elixir_erlang_running_otp_observer_remotely.html
  #   * https://github.com/Stratus3D/dotfiles/blob/master/scripts/tools/epmd_port_forwarder
  #   * https://github.com/Nebo15/k8s-utils
  #   * https://chazsconi.github.io/2017/04/22/observing-remote-elixir-docker-nodes.html
  #
  # http://jbavari.github.io/blog/2016/03/11/using-erlang-observer-on-a-remote-elixir-server/

  ############################################################################
  # INPUT
  ############################################################################

    local HOST_SETUP_PATH="${1? Missing host setup dir!!!}"

    local APP_NAME="${2? Missing app name!!!}"

    local APP_NETWORK="${3? Missing app network!!!}"

    local APP_CONTAINER_NAME="${4? Missing app container_name!!!}"

    local erlang_cookie="${5? Missing the Erlang cookie!!!}"

    local observer_container_username="${6? Missing Observer container user name!!!}"

    shift 6

    Print_Text_With_Label "HOST SETUP DIR" "${HOST_SETUP_PATH}" "3"

    Print_Text_With_Label "APP NAME" "${DOCKER_APP_NAME}" "3"

    Print_Text_With_Label "APP NETWORK" "${APP_NETWORK}" "3"

    Print_Text_With_Label "APP CONTAINER NAME" "${APP_CONTAINER_NAME}" "3"

    Print_Text_With_Label "ERLANG COOKIE" "${erlang_cookie}" "3"

    if ! Docker_Container_Is_Running "${APP_CONTAINER_NAME}"; then
      Print_Fatal_Error "The App container >>> ${APP_CONTAINER_NAME} <<< is not running. Are you in the APP root folder?"
      return
    fi

    local app_ip_address=$( Get_Container_Ip_Address "${APP_CONTAINER_NAME}" )

    Print_Text_With_Label "APP IP ADDRESS" "${app_ip_address}" "3"

    case "${1:-}" in
      "htop" )
        local observer_command="observer-cli ${DOCKER_APP_NAME} ${app_ip_address} ${erlang_cookie}"
        local observer_container_name="${DOCKER_APP_NAME}_observer-htop"
        shift 1
        ;;

      "shell" )
        local observer_command="zsh"
        local observer_container_name="${DOCKER_APP_NAME}_observer-shell"
        shift 1
        ;;

      "" )
        local observer_command="observer ${DOCKER_APP_NAME} ${app_ip_address} ${erlang_cookie}"
        local observer_container_name="${DOCKER_APP_NAME}_observer"
        ;;

      * )
        Print_Fatal_Error "Unsupported: ${input}"

    esac

  ############################################################################
  # CONSTANTS
  ############################################################################

    local OBSERVER_DOCKER_IMAGE="exadra37/observer"


  ############################################################################
  # EXECUTION
  ############################################################################

    if Is_Not_Present_Docker_Image "${OBSERVER_DOCKER_IMAGE}"; then

      Print_Text_With_Label "DOCKER IMAGE" "${OBSERVER_DOCKER_IMAGE}" "0"

      Print_Fatal_Error "Build first the docker image with: elixir build observer-debian"

      exit 1
    fi

    local xauth=$( Setup_X11_Server_Display "${HOST_SETUP_PATH}" )

    Print_Text_With_Label "OBSERVER COMMAND" "${observer_command}" "2"

    ${SUDO_PREFIX} docker run \
      --rm \
      -it \
      --user "${observer_container_username}" \
      --hostname "${observer_container_name}" \
      --name "${observer_container_name}" \
      --network "${APP_NETWORK}" \
      --volume="/tmp/.X11-unix":"/tmp/.X11-unix":ro \
      --volume="${xauth}":"${xauth}":ro \
      --env="XAUTHORITY=${xauth}" \
      "${OBSERVER_DOCKER_IMAGE}" ${observer_command} ${@}
}
