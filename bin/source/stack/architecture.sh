#!/bin/bash

set -eu

Remove_Last_Non_Empty_Line() {
  local file="${1? Missing path to file you want to remove the last non empry line}"
  local content=$(awk 'NR>1 && /./ { print buf; buf=rs=""} { buf=(buf rs $0); rs=RS }' "${file}")
  echo "${content}" > "${file}"
}

Add_Archictecture() {

  local _app_path="${1? Missing the app path, e,g. ./path/to/app/folder}"
  shift 1
  local _check=${1? Missing command to create the resource and actions, e.g. foo:fetch,add,mofify,remove }

  IFS=' ' read -r -a _resources <<< "${@}"

  for _command in "${_resources[@]}"; do

    # from foo:fetch,add we get: foo
    local _resource=${_command%%:*}

    # from foo:fetch,add we get: fetch,add
    local _actions_string=${_command##*:}

    if grep -q "_" <<< "${_resource}"; then
      IFS='_' read -r -a _parts <<< "${_resource}"

      local _resource_capitalized=

      for _part in "${_parts[@]}"; do
        local _capitalized="$(echo ${_part} | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')"
        _resource_capitalized="${_resource_capitalized}${_capitalized}"
      done
    else

      # local _resource_capitalized="${_resource^}"
      # DOESN'T WORK ON FUCKING MACs
      local _resource_capitalized="$(echo ${_resource} | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')"
    fi


    # DOESN'T WORK ON FUCKING MACs
    # local _resource_lowercase="${_resource,,}"
    local _resource_lowercase="$(echo ${_resource} | awk '{$1=tolower($1)}1')"

    local _mix_file_path="${_app_path}/mix.exs"

    # From defmodule HelloWorld.Mixproject do we get: HelloWorld.Mixproject
    local _first_line="$(cat ${_mix_file_path} | head -n 1 | awk '{print $2}')"

    # From HelloWorld.Mixproject we get: HelloWorld
    local _module_name="${_first_line%.*}"

    # From ~/some/absolute/path/hello_world we get: hello_world
    local _app_name="${_app_path##*/}"

    # From mix phx_new hello_world we get: hello_world/lib/hello_world
    local _lib_path="${_app_path}/lib"
    local _lib_app_path="${_app_path}/lib/${_app_name}"
    local _lib_runtime_path="${_lib_path}/runtime"

    if [ -d "${_lib_app_path}" ]; then
      mv "${_lib_app_path}" "${_lib_runtime_path}"
    fi

    IFS=', ' read -r -a _actions <<< "${_actions_string}"

    _Add_Resource
    _Add_Resource_Public_API
    _Add_Resource_Private_API
    _Add_Runtime_Watchdog
    _Add_Runtime_Server
    _Add_Runtime_Apllication

  done
}

# defmodule ApiBaas.AppUsersApi do
#
#   @timeout 5000
#
#   def new_app_users_server() do
#     {:ok, pid} = ApiBaas.Runtime.Application.start_app_users_server()
#     pid
#   end
#
#   def fetch_app_users(pid, attrs) do
#     GenServer.call(pid, {:fetch_app_users, attrs}, @timeout)
#   end
#
#   def add_app_users(pid, attrs) do
#     GenServer.call(pid, {:add_app_users, attrs}, @timeout)
#   end
#
#   def modify_app_users(pid, attrs) do
#     GenServer.call(pid, {:modify_app_users, attrs}, @timeout)
#   end
#
#   def remove_app_users(pid, attrs) do
#     GenServer.call(pid, {:remove_app_users, attrs}, @timeout)
#   end
#
# end
_Add_Resource_Public_API() {

  local _api_file_path="${_lib_path}/${_resource_lowercase}_api.ex"

  rm -f "${_lib_path}/${_app_name}.ex"

  ### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
cat <<EOF > "${_api_file_path}"
defmodule ${_module_name}.${_resource_capitalized}Api do

  @timeout 5000

  def new_${_resource_lowercase}_server() do
    {:ok, pid} = ${_module_name}.Runtime.Application.start_${_resource_lowercase}_server()
    pid
  end

EOF

  for action in "${_actions[@]}"; do
    local _action_capitalised="${action^}"
    local _action_lowercase="${action,,}"

### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
cat <<EOF >> "${_api_file_path}"
  def ${_action_lowercase}_${_resource_lowercase}(pid, attrs) do
    GenServer.call(pid, {:${_action_lowercase}_${_resource_lowercase}, attrs}, @timeout)
  end

EOF

  done

  printf "end\n" >> "${_api_file_path}"
}


# defmodule ApiBaas.AppUsersPrivateApi do
#
#   def fetch_app_users(pid, attrs) do
#      ApiBaas.Resources.AppUsersFetchContext.fetch_app_users(attrs)
#   end
#
#   def add_app_users(pid, attrs) do
#      ApiBaas.Resources.AppUsersAddContext.add_app_users(attrs)
#   end
#
#   def modify_app_users(pid, attrs) do
#      ApiBaas.Resources.AppUsersModifyContext.modify_app_users(attrs)
#   end
#
#   def remove_app_users(pid, attrs) do
#      ApiBaas.Resources.AppUsersRemoveContext.remove_app_users(attrs)
#   end
#
# end
_Add_Resource_Private_API() {

  local _api_file_path="${_lib_path}/${_resource_lowercase}_private_api.ex"

  rm -f "${_lib_path}/${_app_name}.ex"

  ### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
cat <<EOF > "${_api_file_path}"
defmodule ${_module_name}.${_resource_capitalized}PrivateApi do

EOF

  for action in "${_actions[@]}"; do
    local _action_capitalised="${action^}"
    local _action_lowercase="${action,,}"

### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
cat <<EOF >> "${_api_file_path}"
  def ${_action_lowercase}_${_resource_lowercase}(pid, attrs) do
     ${_module_name}.Resources.${_resource_capitalized}${_action_capitalised}Context.${_action_lowercase}_${_resource_lowercase}(attrs)
  end

EOF

  done

  printf "end\n" >> "${_api_file_path}"
}


# defmodule Watchdog do
#
#   def start(expire_time_milleseconds) do
#     spawn_link(fn -> watcher(expire_time_milleseconds) end)
#   end
#
#   def im_alive(watcher) do
#     send(watcher, :im_alive)
#   end
#
#   defp watcher(expire_time_milleseconds) do
#     receive do
#       :im_alive ->
#         watcher(expire_time_milleseconds)
#
#     after
#       expire_time_milleseconds ->
#         Process.exit(self(), {:shutdown, :watchdog_triggered})
#     end
#   end
#
# end
_Add_Runtime_Watchdog() {

  local watchdog_file="${_lib_path}/runtime/watchdog.ex"

  if [ -f "${watchdog_file}" ]; then
    return
  fi

cat <<EOF > "${watchdog_file}"
defmodule Watchdog do

  def start(expire_time_milleseconds) do
    spawn_link(fn -> watcher(expire_time_milleseconds) end)
  end

  def im_alive(watcher) do
    send(watcher, :im_alive)
  end

  defp watcher(expire_time_milleseconds) do
    receive do
      :im_alive ->
        watcher(expire_time_milleseconds)

    after
      expire_time_milleseconds ->
        Process.exit(self(), {:shutdown, :watchdog_triggered})
    end
  end

end

EOF
}

# defmodule ApiBaas.Runtime.Application do
#   # See https://hexdocs.pm/elixir/Application.html
#   # for more information on OTP Applications
#   @moduledoc false
#
#   use Application
#
#   @impl true
#   def start(_type, _args) do
#     children = [
#       { DynamicSupervisor, strategy: :one_for_one, name: ApiBaas.AppsDynamicSupervisor },
#
#       { DynamicSupervisor, strategy: :one_for_one, name: ApiBaas.AppUsersDynamicSupervisor },
#
#       # Starts a worker by calling: ApiBaas.Worker.start_link(arg)
#       # {ApiBaas.Worker, arg}
#     ]
#
#     # See https://hexdocs.pm/elixir/Supervisor.html
#     # for other strategies and supported options
#     opts = [strategy: :one_for_one, name: ApiBaas.Supervisor]
#     Supervisor.start_link(children, opts)
#   end
#
#   def start_app_users_server() do
#     DynamicSupervisor.start_child(ApiBaas.AppUsersDynamicSupervisor, { ApiBaas.Runtime.AppUsersServer, nil })
#   end
#
#   def start_apps_server() do
#     DynamicSupervisor.start_child(ApiBaas.AppsDynamicSupervisor, { ApiBaas.Runtime.AppsServer, nil })
#   end
#
# end
_Add_Runtime_Apllication() {

  local _application_file_path="${_lib_runtime_path}/application.ex"

  if ! grep -qw "${_module_name}.Runtime.Application," "${_mix_file_path}" 2&> /dev/null; then
    sed -i -e "s/${_module_name}.Application,/${_module_name}.Runtime.Application,/" "${_mix_file_path}"
  fi

  if ! grep -qw "${_module_name}.Runtime.Application," "${_application_file_path}" 2&> /dev/null; then
    sed -i -e "s/defmodule ${_module_name}.Application do/defmodule ${_module_name}.Runtime.Application do/" "${_application_file_path}"
  fi

  local _line="{ DynamicSupervisor, strategy: :one_for_one, name: ${_module_name}.${_resource_capitalized}DynamicSupervisor }"

  if ! grep -qw "${_line}" "${_application_file_path}" 2&> /dev/null; then
    sed -i -e "s/children = \[/children = \[\\n      ${_line},\\n/" "${_application_file_path}"
  fi

  if ! grep -qw "def start_${_resource_lowercase}_server()" "${_application_file_path}" 2&> /dev/null; then
    Remove_Last_Non_Empty_Line "${_application_file_path}"

cat << EOF >> "${_application_file_path}"

  def start_${_resource_lowercase}_server() do
    DynamicSupervisor.start_child(${_module_name}.${_resource_capitalized}DynamicSupervisor, { ${_module_name}.Runtime.${_resource_capitalized}Server, nil })
  end

end
EOF

  fi
}


# defmodule ApiBaas.Runtime.AppsServer do
#
#   use GenServer
#
#   # @type t :: pid()
#
#   @idle_timeout_milleseconds 1 * 60 * 60 * 1000 # 1 hour
#
#   ### Runs in the Client Process
#
#   def start_link(_args) do
#     GenServer.start_link(__MODULE__, nil)
#   end
#
#
#   ### Runs in this Server Process
#
#   def init(initial_state \\ %{}) do
#     watcher = Watchdog.start(@idle_timeout_milleseconds)
#     { :ok, {initial_state, watcher} }
#   end
#
#   def handle_call({:fetch_apps, attrs}, _from, {state, watcher}) do
#     Watchdog.im_alive(watcher)
#     result = ApiBaas.AppsPrivateApi.fetch_apps(attrs)
#     { :reply, result, {state, watcher} }
#   end
#
#   def handle_call({:add_apps, attrs}, _from, {state, watcher}) do
#     Watchdog.im_alive(watcher)
#     result = ApiBaas.AppsPrivateApi.add_apps(attrs)
#     { :reply, result, {state, watcher} }
#   end
#
#   def handle_call({:modify_apps, attrs}, _from, {state, watcher}) do
#     Watchdog.im_alive(watcher)
#     result = ApiBaas.AppsPrivateApi.modify_apps(attrs)
#     { :reply, result, {state, watcher} }
#   end
#
#   def handle_call({:remove_apps, attrs}, _from, {state, watcher}) do
#     Watchdog.im_alive(watcher)
#     result = ApiBaas.AppsPrivateApi.remove_apps(attrs)
#     { :reply, result, {state, watcher} }
#   end
#
# end
_Add_Runtime_Server() {

  local server_file="${_lib_path}/runtime/${_resource_lowercase}_server.ex"

  if [ -f "${server_file}" ]; then
    return
  fi

cat <<EOF > "${server_file}"
defmodule ${_module_name}.Runtime.${_resource_capitalized}Server do

  use GenServer

  # @type t :: pid()

  @idle_timeout_milleseconds 1 * 60 * 60 * 1000 # 1 hour

  ### Runs in the Client Process

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end


  ### Runs in this Server Process

  def init(initial_state \\\ %{}) do
    watcher = Watchdog.start(@idle_timeout_milleseconds)
    { :ok, {initial_state, watcher} }
  end

EOF

for action in "${_actions[@]}"; do
    local _action_capitalised="${action^}"
    local _action_lowercase="${action,,}"
cat <<EOF >> "${server_file}"
  def handle_call({:${_action_lowercase}_${_resource_lowercase}, attrs}, _from, {state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}.${_resource_capitalized}PrivateApi.${_action_lowercase}_${_resource_lowercase}(attrs)
    { :reply, result, {state, watcher} }
  end

EOF
done

  echo "end" >> "${server_file}"
}

# defmodule ApiBaas.Resources.AppUsersAddContext do
#
#   def add_app_users(attrs) do
#     # your logic goes here...
#     attrs
#   end
#
# end
_Add_Resource() {

  local resources_path="${_lib_path}/resources"

  local _resource_path="${resources_path}/${_resource_lowercase}"

  for action in "${_actions[@]}"; do
    local _action_capitalised="${action^}"
    local _action_lowercase="${action,,}"

    mkdir -p "${_resource_path}/${_action_lowercase}"

    local context_file="${_resource_path}/${_action_lowercase}/${_resource_lowercase}_context.ex"

    if [ -f "${context_file}" ]; then
      continue
    fi

    local _line="defmodule ${_module_name}.Resources.${_resource_capitalized}${_action_capitalised}Context do"

    if ! grep -qw "${_line}" "${context_file}" 2&> /dev/null; then
      printf "${_line}\n\n" > "${context_file}"
    fi

    if ! grep -qw "def ${_action_lowercase}_${_resource_lowercase}(attrs) do" "${context_file}" 2&> /dev/null; then
cat <<EOF >> "${context_file}"
  def ${_action_lowercase}_${_resource_lowercase}(attrs) do
    # your logic goes here...
    attrs
  end

EOF
    fi

    echo "end" >> "${context_file}"
  done

}

Main() {
  for input in "${@}"; do
    case "${input}" in

      --add-architecture )
          shift 1
          Add_Archictecture "${@}"
          exit $?
        ;;
    esac
  done
}

Main "${@}"
