#!/bin/sh

set -eu

Build_Database_Type()
{
  ############################################################################
  # INPUT
  ############################################################################

    local database_image="${1? Missing database image name !!!}"


  ############################################################################
  # VARS
  ############################################################################

    # exadra37/postgres:alpine -> exadra37/postgres
    local database_image="${database_image%%:*}"

    # exadra37/postgres -> postgres
    local database_type="${database_image##*/}"


  ############################################################################
  # EXECUTION
  ############################################################################

    echo -n "${database_type}"
}

Build_Database_Data_Path()
{
  ############################################################################
  # INPUT
  ############################################################################

    local database_image="${1? Missing database image name !!!}"


  ############################################################################
  # VARS
  ############################################################################

    local database_type="$( Build_Database_Type ${database_image} )"


  ############################################################################
  # EXECUTION
  ############################################################################

    echo -n "${HOST_SETUP_PATH}/database/${database_type}"/data
}

Build_Database_Container_Name()
{
  ############################################################################
  # INPUT
  ############################################################################

    local database_image="${1? Missing database image name !!!}"


  ############################################################################
  # VARS
  ############################################################################

    local database_type="$( Build_Database_Type ${database_image} )"


  ############################################################################
  # EXECUTION
  ############################################################################

    echo -n "${APP_NAME}_${database_type}_db"
}

Attach_To_Database_Container()
{
  Print_Text_With_Label "FUNCTION" "Attach_To_Database_Container" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local database_container_name="${1? Missing database container name!!!}"

    local database_user="${2? Missing database user !!!}"

    local databse_execute_command="${3? Missing database command to execute in the container !!!}"

    shift 3

    local args="${@}"



  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "INVOKED COMMAND" "${databse_execute_command} ${args}" "2"

    if [ "${databse_execute_command}" = "postgres" ]; then
      Print_Text_With_Label "WARNING" "Postgres database is already running. You can only attach to run commands, eg: createdb ..." "1"
      return
    fi

    ${SUDO_PREFIX} docker exec \
      -it \
      --user "${database_user}" \
      "${database_container_name}" \
      ${databse_execute_command} ${args}
}

Start_Or_Attach_To_Database_Container()
{
  Print_Text_With_Label "FUNCTION" "Start_Or_Attach_To_Database_Container" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local database_image="${1? Missing database image name !!!}"

    local database_user="${2? Missing database user !!!}"

    local background_mode="${3? Missing background mode to run the container!!!}"

    local databse_execute_command="${4? Missing command to run in the container!!!}"

    shift 4

    local args="${@}"

    local database_container_name="$( Build_Database_Container_Name ${database_image} )"

    local database_data_dir="$( Build_Database_Data_Path ${database_image} )"


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "DATABASE IMAGE" "${database_image}" "2"
    Print_Text_With_Label "DATABASE CONTAINER" "${database_container_name}" "2"

    if [ ! -d "${database_data_dir}" ]; then

      Print_Text_With_Label "CHECK POINT" "Fixing database data dir permissions!!!" "4"

      local user_uid=$( Get_Container_Username_UID "${database_image}" "${database_user}" )

      Print_Text_With_Label "USER UID (${database_user})" "${user_uid}" "3"

      mkdir -p "${database_data_dir}"

      ${SUDO_PREFIX} chown -R ${user_uid}:${user_uid} "${database_data_dir}/.."
    fi

    if Docker_Container_Is_Running "${database_container_name}"; then

      Attach_To_Database_Container \
        "${database_container_name}" \
        "${database_user}" \
        ${databse_execute_command}

      return 0
    fi

    Create_Docker_Network_If_Not_Exists "${APP_NETWORK}"

    Print_Text_With_Label "INVOKED COMMAND" "${databse_execute_command} ${args}" "2"

    # @TODO Add support to use POSTGRES_PASSWORD from .env file
    # --env POSTGRES_PASSWORD="${POSTGRES_PASSWORD? Set password for the Postgres root user in the .env file: POSTGRES_PASSWORD=your-root-password}" \
    ${SUDO_PREFIX} docker run \
      --rm \
      "${background_mode}" \
      --env POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}" \
      --hostname "${APP_NAME}_db" \
      --user "${database_user}" \
      --name "${database_container_name}" \
      --network "${APP_NETWORK}" \
      --volume "${database_data_dir}":/var/lib/postgresql/data \
      "${database_image}" ${databse_execute_command} ${args}
}

Run_Database_Command()
{
  Print_Text_With_Label "FUNCTION" "Run_Database_Command" "4"

  ############################################################################
  # INPUT
  ############################################################################

    local database_image="${1? Missing database image name !!!}"

    local database_user="${2? Missing database user !!!}"

    local start_database_command="${3? Missing command to start database!!!}"

    local seconds_to_wait_database_is_running="${4? Missing seconds to wait database to be running!!!}"

    local background_mode="${5? Missing background mode to run the container!!!}"

    local databse_execute_command="${6? Missing command to run in the container!!!}"

    shift 6


  ############################################################################
  # VARS
  ############################################################################

    local database_container_name="$( Build_Database_Container_Name ${database_image} )"


  ############################################################################
  # EXECUTION
  ############################################################################

    Print_Text_With_Label "INVOKED COMMAND" "${databse_execute_command}" "4"

    if ! Docker_Container_Is_Running "${database_container_name}"; then

      Start_Or_Attach_To_Database_Container \
        "${database_image}" \
        "${database_user}" \
        "--detach" \
        "${start_database_command}"

      Print_Text "Waiting for database engine to start..." "0"

      sleep ${seconds_to_wait_database_is_running}
    fi

    Start_Or_Attach_To_Database_Container \
      "${database_image}" \
      "${database_user}" \
      "-it" \
      "${databse_execute_command}"
}
