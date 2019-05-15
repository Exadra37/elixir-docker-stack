#!/bin/sh

set -eu

Setup_X11_Server_Display()
{
  ############################################################################
  # INPUT
  ############################################################################

    local host_setup_path="${1? Missing host setup dir!!!}"

    local xauth_display="${2:-:0}"


  ############################################################################
  # VARS
  ############################################################################

    local xauth="${host_setup_path}"/.docker.xauth


  ############################################################################
  # EXECUTION
  ############################################################################

    # @link http://wiki.ros.org/docker/Tutorials/GUI#The_isolated_way
    touch "${xauth}"
    xauth nlist "${xauth_display}" | sed -e 's/^..../ffff/' | xauth -f "${xauth}" nmerge -

    echo "${xauth}"
}

Is_Not_Present_Docker_Image()
{
  ############################################################################
  # INPUT
  ############################################################################

    local _image_name="${1}"

  ############################################################################
  # EXECUTION
  ############################################################################

    [ -z $( ${SUDO_PREFIX} docker images -q "${_image_name}" ) ] && return 0 || return 1
}

Docker_Container_Is_Running()
{
  ############################################################################
  # INPUT
  ############################################################################

    local container_name="${1? Missing container name!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    ${SUDO_PREFIX} docker container ls -a | grep -qw "${container_name}" -

    return $?
}

Get_Container_Ip_Address()
{
  ############################################################################
  # INPUT
  ############################################################################

    local container_name="${1? Missing container name!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    echo -n $( ${SUDO_PREFIX} docker exec -it ${container_name} sh -c 'echo -n $(hostname -i)' )
}

Get_Container_Username_UID()
{
  ############################################################################
  # INPUT
  ############################################################################

    local docker_image="${1? Missing docker image!!!}"
    local user_name="${2? Missing user name to get the UID!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    echo -n $( ${SUDO_PREFIX} docker run --rm -it --user ${user_name} ${docker_image} sh -c 'echo -n $(id -u)' )
}

Get_Docker_Image_Tag()
{
  ############################################################################
  # INPUT
  ############################################################################

    local elixir_version="${1? Missing Elixir Version!!!}"

    local phoenix_version="${2? Missing Phoenix version!!!}"

    local dockerfile="${3? Missing variant for docker image!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    if [ "${dockerfile}" = "observer-debian" ]; then
      echo "${elixir_version}"
    else
      echo "${elixir_version}_${phoenix_version}_${dockerfile}"
    fi
}

Create_Docker_Network_If_Not_Exists()
{
  ############################################################################
  # INPUT
  ############################################################################

    local network_name="${1? Missing network name!!!}"

  ############################################################################
  # EXECUTION
  ############################################################################

    ${SUDO_PREFIX} docker network create "${network_name}" &> /dev/null || true
}

Create_Docker_Volume()
{
  ############################################################################
  # INPUT
  ############################################################################

    local container_name="${1? Missing container name!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "CREATING DOCKER VOLUME:" "${container_name}" "2"

    ${SUDO_PREFIX} docker volume create "${container_name}"
}

Stop_And_Remove_Docker_Containers()
{
  ############################################################################
  # EXECUTION
  ############################################################################

    for container_name in "${@}"; do

      if Docker_Container_Is_Running "${container_name}" ; then

        # no need to remove the containers explicitly, once they where started
        # with the `--rm` flag
        ${SUDO_PREFIX} docker stop "${container_name}"
      fi

    done
}

Remove_Docker_Network()
{
  ############################################################################
  # INPUT
  ############################################################################

    local network_name="${1? Missing network name!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    ${SUDO_PREFIX} docker network rm "${network_name}"
}

Remove_Docker_Network_If_Not_Active()
{
  ############################################################################
  # INPUT
  ############################################################################

    local network_name="${1? Missing network name!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    ${SUDO_PREFIX} docker network rm "${network_name}" 2&> /dev/null
}


Remove_Docker_Network_If_Container_Is_Not_Running()
{
  ############################################################################
  # INPUT
  ############################################################################

    local network_name="${1? Missing network name !!!}"

    local container_name="${1? Missing container name !!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    if ! Docker_Container_Is_Running "${container_name}"; then
      Remove_Docker_Network "${network_name}"
    fi
}
