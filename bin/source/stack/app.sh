#/bin/sh

set -eu

Replace_IP_Address() {

  Print_Text_With_Label "FUNCTION" "Replace_IP_Address" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local ip_address="${1? Missing the http port for the Phoenix app !!!}"

    local path_prefix="${2? Missing the path prefix for the project !!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "ip_address: " "${ip_address}" "1"

    # Fix the http port in the App configuration file.
    if [ -f "${path_prefix}/config/dev.exs" ]; then
      sed -i -e "s/ip: {127, 0, 0, 1}/ip: ${ip_address}/g" ${path_prefix}/config/dev.exs
    fi

    if [ -f "${path_prefix}/config/test.exs" ]; then
      sed -i -e "s/ip: {127, 0, 0, 1}/ip: ${ip_address}/g" ${path_prefix}/config/test.exs
    fi
}

Replace_Http_Port() {

  Print_Text_With_Label "FUNCTION" "Replace_Http_Port" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local http_port="${1? Missing the http port for the Phoenix app !!!}"

    local path_prefix="${2? Missing the path prefix for the project !!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "HTTP_PORT: " "${http_port}" "1"

    # Fix the http port in the App configuration file.
    if [ -f "${path_prefix}/config/dev.exs" ]; then
      sed -i -e "s/port: 4000/port: ${http_port}/g" ${path_prefix}/config/dev.exs
    fi

    if [ -f "${path_prefix}/config/test.exs" ]; then
      sed -i -e "s/port: 4000/port: ${http_port}/g" ${path_prefix}/config/test.exs
    fi
}

Set_App_Global_Paths()
{
  Print_Text_With_Label "FUNCTION" "Is_Phoenix_App" "4"

  ############################################################################
  # EXECUTION
  ############################################################################

    if Is_Umbrella_App "${PWD}/.."; then
      APP_HOST_DIR="${PWD}/.."
      APP_CONTAINER_RELATIVE_PATH=workspace/apps
      return
    fi

    if Is_Umbrella_App "${PWD}/../.."; then
      APP_HOST_DIR="${PWD}/../.."
      APP_CONTAINER_RELATIVE_PATH=workspace/apps/"${APP_FOLDER_NAME}"
      return
    fi

    if Is_App_With_Path_Dependencies "${PWD}"; then
      APP_HOST_DIR="${PWD}/.."
      APP_CONTAINER_RELATIVE_PATH=workspace/"${APP_FOLDER_NAME}"
      return
    fi
}

Is_Phoenix_App()
{
  Print_Text_With_Label "FUNCTION" "Is_Phoenix_App" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local APP_FOLDER_NAME="${1? Missing App name to check if is a Phoenix app !!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    if [ -f ./mix.exs ]; then
      grep -qw ":phoenix," ./mix.exs 2&> /dev/null
      return $?
    fi

    if [ -f "./apps/${APP_FOLDER_NAME}"/mix.exs ]; then
      grep -qw ":phoenix," "./apps/${APP_FOLDER_NAME}"/mix.exs 2&> /dev/null
      return $?
    fi

    Print_Text_With_Label "Is_Phoenix_App" "false" "3"

    # Not a Phoenix App.
    return 1
}

Is_Umbrella_App()
{
  Print_Text_With_Label "FUNCTION" "Is_Umbrella_App" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local path="${1? Missing path to check if is an umbrella app !!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    if [ -f "${path}"/mix.exs ]; then
      grep -qw "apps_path:" "${path}"/mix.exs 2&> /dev/null
      return $?
    fi

    # Not an Umbrella App.
    return 1
}

Is_App_With_Path_Dependencies()
{
  Print_Text_With_Label "FUNCTION" "Is_App_With_Path_Dependencies" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local path="${1? Missing path to check if is an app path dependencies !!!}"

    Print_Text_With_Label "PATH" "${path}" "4"


  ############################################################################
  # EXECUTION
  ############################################################################

    if [ -f "${path}"/mix.exs ]; then
      grep -q 'path: "../' "${path}"/mix.exs 2&> /dev/null
      return $?
    fi

    # Not an App with path dependencies.
    return 1
}

Is_App_With_Database()
{
  ############################################################################
  # VARS
  ############################################################################

    local config_file=${APP_PATH}/config/dev.exs


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "Config file Path" "${config_file}" "3"

    # Converts `my_APP_NAME` to `myappname` do that we can use a grep case
    # insensitive search on the string `MyAppName.Repo`.
    local repo_name="${APP_NAME//[^[:alnum:]]/}.Repo"
    Print_Text_With_Label "Repository Name" "${repo_name}" "3"

    grep -iq "${repo_name}," "${config_file}" 2&> /dev/null

    return $?
}

Add_Database_If_Required()
{
  if Is_App_With_Database; then

    # Pinning database defaults to be used each time we run the Elixir Docker Stack
    echo "EDS_DATABASE_IMAGE=${EDS_DATABASE_IMAGE}" >> "${APP_PATH}/${stack_defaults_file}"
    echo "EDS_DATABASE_USER=${EDS_DATABASE_USER}" >> "${APP_PATH}/${stack_defaults_file}"
    echo "EDS_DATABASE_COMMAND=${EDS_DATABASE_COMMAND}" >> "${APP_PATH}/${stack_defaults_file}"

    local database_container_name="$( Build_Database_Container_Name ${EDS_DATABASE_IMAGE} )"

    # Fix the database hostname in the App configuration file.
    sed -i -e "s/hostname: \"localhost\"/hostname: \"${database_container_name}\"/g" ${APP_PATH}/config/dev.exs
    sed -i -e "s/hostname: \"localhost\"/hostname: \"${database_container_name}\"/g" ${APP_PATH}/config/test.exs
  fi
}


Attach_To_App_Container()
{
  Print_Text_With_Label "FUNCTION" "Attach_To_App_Container" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local container_username="${1? Missing container user name!!!}"

    local background_mode="${2? Missing backround mode to run the container!!!}"

    local mix_env="${3? Missing mix env value!!!}"

    local app_container_command="${4? Missing command to run in the container!!!}"

    shift 4

    local args="${@}"


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "ATTACHING TO CONTAINER" "${APP_CONTAINER_NAME}" "1"

    Print_Text_With_Label "INVOKED COMMAND" "${app_container_command} ${args}" "2"

    Print_Text_With_Label "BACKGROUND MODE" "${background_mode}" "3"

    APP_NODE_NAME="${APP_NAME}@$( Get_Container_Ip_Address ${APP_CONTAINER_NAME} )"

    ${SUDO_PREFIX} docker exec \
      --user ${container_username} \
      ${CONTAINER_ENV} \
      --env "MIX_ENV=${mix_env}" \
      --env "APP_NODE_NAME=${APP_NODE_NAME}" \
      --env "APP_NODE_COOKIE=${ERLANG_COOKIE}" \
      --env "PORT=${EDS_CONTAINER_HTTP_PORT}" \
      --env "APP_HTTP_PORT=${EDS_APP_HTTP_PORT}" \
      --env "APP_HTTPS_PORT=${EDS_APP_HTTPS_PORT}" \
      ${background_mode} \
      ${APP_CONTAINER_NAME} \
      ${app_container_command} ${args}
}

Start_Or_Attach_To_App_Container()
{
  Print_Text_With_Label "FUNCTION" "Start_Or_Attach_To_App_Container" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local stack_name="${1? Missing stack name !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    local app_http_port="${3? Missing port map!!!}"

    local os_name="${4? Missing operating system name !!!}"

    local os_version="${5? Missing operating system version !!!}"

    local is_local_docker_image="${6? Missing if is a local docker image !!!}"

    local erlang_otp_version="${7? Missing Erlang version!!!}"

    local elixir_version="${8? Missing Elixir version!!!}"

    local phoenix_version="${9? Missing Phoenix version!!!}"

    local container_username="${10? Missing container user name!!!}"

    local mix_env="${11? Missing mix env value!!!}"

    local env_file="${12? Missing the env file!!!}"

    local background_mode="${13? Missing backround mode to run the container!!!}"

    local app_container_command="${14? Missing command to run in the container!!!}"

    shift 14

    local args="${@}"


  ############################################################################
  # VARS
  ############################################################################

    local image_tag="$( Build_Docker_Stack_Tag ${stack_name} ${stack_build_source} ${phoenix_version} ${elixir_version} ${erlang_otp_version} ${os_name} ${os_version}  )"

    local image_name=$( Build_Docker_Image_Name "${stack_name}" )

    local docker_image="${image_name}:${image_tag}"

    local xauth_sock="/tmp/.X11-unix"

    local xauth=$( Setup_X11_Server_Display "${HOST_SETUP_PATH}" )

    #local publish_ports=""

    # if [ "${stack_port_map}" != ":" ]; then
    #   local publish_ports="--publish 127.0.0.1:${stack_port_map}"
    # fi

    Set_App_Global_Paths

    Print_Text_With_Label "APP_HOST_DIR" "${APP_HOST_DIR}" "2"

    Print_Text_With_Label "APP_CONTAINER_RELATIVE_PATH" "${APP_CONTAINER_RELATIVE_PATH}" "2"


  ############################################################################
  # EXECUTION
  ############################################################################

    if Is_Not_Present_Docker_Image "${docker_image}"; then

      Print_Text_With_Label "DOCKER IMAGE" "${docker_image}" "0"

      Print_Text_With_Label "WARNING" "Missing docker image for >>> ${APP_NAME} <<< APP. Please wait until we build the image." "1"

      Build_Docker_Stack \
        "${stack_name}" \
        "${stack_build_source}" \
        "${phoenix_version}" \
        "${elixir_version}" \
        "${erlang_otp_version}" \
        "${os_name}" \
        "${os_version}" \
        "${is_local_docker_image}"
    fi

    if Is_App_With_Database; then

      Start_Or_Attach_To_Database_Container \
        "${EDS_DATABASE_IMAGE}" \
        "${EDS_DATABASE_USER}" \
        "--detach" \
        "${EDS_DATABASE_COMMAND}"
    fi

    if Docker_Container_Is_Running "${APP_CONTAINER_NAME}"; then

      Attach_To_App_Container \
        "${container_username}" \
        "${background_mode}" \
        "${mix_env}" \
        "${app_container_command}" \
        ${@}

      exit 0
    fi

    Print_Text_With_Label "STARTING DOCKER IMAGE" "${docker_image}" "1"

    Print_Text_With_Label "INVOKED COMMAND" "${app_container_command} ${args}" "2"

    Print_Text_With_Label "CONTAINER USERNAME" "${container_username}" "3"

    Print_Text_With_Label "APP NETWORK" "${APP_NETWORK}" "3"

    local env_file_option=""

    if [ -f "${env_file}" ]; then
        local env_file_option="--env-file ${env_file}"
    fi

    local iex_file="${ELIXIR_DOCKER_STACK_INSTALL_DIR}/bin/.iex.exs"

    if [ -f ~/.iex.exs ]; then
      iex_file=~/.iex.exs
    fi

    local _publish_ports=""

    if [ ${IS_TO_PUBLISH_PORTS} == "true" ]; then
      _publish_ports="--publish ${EDS_APP_IP}:${EDS_APP_HTTP_PORT}:${EDS_CONTAINER_HTTP_PORT}"
      _publish_ports="${_publish_ports} --publish ${EDS_APP_IP}:${EDS_APP_HTTPS_PORT}:${EDS_CONTAINER_HTTPS_PORT}"
    fi

    local _erlang_cookie_path=""

    local _user="${HOME?The \$USER var is not set in the environment}"

    if [ -f ~/.erlang.cookie ]; then
      _erlang_cookie_path=/home/{_user}/.erlang.cookie
    fi

    if [ -f ./.erlang.cookie ]; then
      _erlang_cookie_path="${PWD}"/.erlang.cookie
    fi

    if [ -z "${_erlang_cookie_path}" ]; then
      local _cookie="$(Random_Cookie_String)"
      echo "${_cookie}" > ~/.erlang.cookie
      _erlang_cookie_path=/home/{_user}/.erlang.cookie
    fi

    Create_Docker_Network_If_Not_Exists "${APP_NETWORK}"

    mkdir -p "${APP_HOST_DIR}"/.local/mix

    # Raises an Erlang error when starting the iex session with `iex --name user@example.com`.
    # It works if we start the iex session with the `--cookie mycookie` flag.
    # --volume "${_erlang_cookie_path}":/home/"${container_username}"/.erlang.cookie \

    ${SUDO_PREFIX} docker run \
      --rm \
      ${background_mode} \
      ${env_file_option} \
      ${CONTAINER_ENV} \
      ${_publish_ports} \
      --env "PORT=${EDS_CONTAINER_HTTP_PORT}" \
      --env "APP_HTTP_PORT=${EDS_APP_HTTP_PORT}" \
      --env "APP_HTTPS_PORT=${EDS_APP_HTTPS_PORT}" \
      --env "APP_NODE_NAME=${APP_NODE_NAME}" \
      --env "APP_NODE_COOKIE=${ERLANG_COOKIE}" \
      --env "MIX_ENV=${mix_env}" \
      --env "XAUTHORITY=${xauth}" \
      --env SSH_AUTH_SOCK=/ssh-agent \
      --volume $SSH_AUTH_SOCK:/ssh-agent:ro \
      --volume ~/.ssh/:/home/developer/.ssh:ro \
      --name "${APP_CONTAINER_NAME}" \
      --hostname "${APP_NAME}" \
      --user "${container_username}" \
      --network "${APP_NETWORK}" \
      --workdir /home/"${container_username}/${APP_CONTAINER_RELATIVE_PATH}" \
      --volume "${iex_file}":/home/"${container_username}"/.iex.exs \
      --volume "${APP_HOST_DIR}"/.local/mix/:/home/"${container_username}"/.cache/mix/ \
      --volume "${APP_HOST_DIR}":/home/"${container_username}"/workspace \
      --volume "${APP_CONTAINER_NAME}_${image_tag}_var_lib_postgresql":/var/lib/postgresql \
      --volume "${APP_CONTAINER_NAME}_${image_tag}_var_log_postgresql":/var/log/postgresql \
      --volume "${APP_CONTAINER_NAME}_${image_tag}_config_sublimetext_3":/home/"${container_username}"/.config/sublime-text-3 \
      --volume "/tmp/.X11-unix":"/tmp/.X11-unix":ro \
      --volume "${xauth}":"${xauth}":ro \
      "${docker_image}" \
      ${app_container_command} ${args}
}

Start_Dummy_App_Container()
{
  ############################################################################
  # INPUT
  ############################################################################

    local stack_name="${1? Missing stack name !!!}"

    local stack_build_source="${2? Missing the build source for the docker stack being built !!!}"

    local app_http_port="${3? Missing port map!!!}"

    local os_name="${4? Missing operating system name !!!}"

    local os_version="${5? Missing operating system version !!!}"

    local is_local_docker_image="${6? Missing if is a local docker image !!!}"

    local erlang_otp_version="${7? Missing Erlang version!!!}"

    local elixir_version="${8? Missing Elixir version!!!}"

    local phoenix_version="${9? Missing Phoenix version!!!}"

    local container_username="${10? Missing container user name!!!}"

    local mix_env="${11? Missing mix env value!!!}"

    local env_file="${12? Missing the env file!!!}"

    local seconds_to_wait_dummy_app_is_ready="${13? Missing seconds to wait until dummy app container is ready!!!}"


  ############################################################################
  # EXECUTION
  ############################################################################

    # We need a dummy Docker container running before we start any real
    # process on it, so that we can run Elixir or Phoenix apps with a full
    # qualified node name, byt getting the IP address of the dummy container.
    if ! Docker_Container_Is_Running "${APP_CONTAINER_NAME}"; then

      Print_Text "STARTING A DUMMY CONTAINER" "4"

      Start_Or_Attach_To_App_Container \
        "${stack_name}" \
        "${stack_build_source}" \
        "${app_http_port}" \
        "${os_name}" \
        "${os_version}" \
        "${is_local_docker_image}" \
        "${erlang_otp_version}" \
        "${elixir_version}" \
        "${phoenix_version}" \
        "${container_username}" \
        "${mix_env}" \
        "${env_file}" \
        "-td" \
        ""

        # need to give time for the container be available, before we try to
        # attach to it in the next command.
        sleep ${seconds_to_wait_dummy_app_is_ready}
  fi
}
