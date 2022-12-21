#!/bin/bash

set -eu

Add_Archictecture() {

  local _app_path="${1? Missing the app path, e,g. ./path/to/app/folder}"
  shift 1
  local _check=${1? Missing command to create the resource and actions, e.g. foo:fetch,add,mofify,remove }

  IFS=' ' read -r -a _resources <<< "${@}"

  for _command in ${_resources[@]}; do

    # from foo:fetch,add we get: foo
    local _resource=${_command%%:*}

    # from foo:fetch,add we get: fetch,add
    local _actions_string=${_command##*:}

    # DOESN'T WORK ON FUCKING MACs
    # local _resource_capitalized="${_resource^}"
    local _resource_capitalized="$(echo ${_resource} | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')"

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

    if [ -f "${_lib_app_path}" ]; then
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

  # for action in "${_actions[@]}"; do
  #   local _action_capitalised="${action^}"
  #   local _action_lowercase="${action,,}"
  #   # echo $(_Build_Action)
  #   _Add_Runtime
  #   _Add_Resource
  # done
}

# defmodule OnlineShop.ProductApi do
#
#   alias OnlineShop.Runtime.ProductServer
#
#   @timeout 5000
#
#   def new_product_server() do
#     {:ok, pid} = OnlineShop.Runtime.Application.start_product_server()
#     pid
#   end
#
#   def fetch_product(pid, uuid) do
#     GenServer.call(pid, {:fetch_product, uuid}, @timeout)
#   end
#
#   def add_product(pid, uuid) do
#     GenServer.call(pid, {:add_product, uuid}, @timeout)
#   end
#
# end
_Add_Resource_Public_API() {

  local _api_file_path="${_lib_path}/${_resource_lowercase}_api.ex"

  rm -f "${_lib_path}/${_app_name}.ex"

  ### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
cat <<EOF > "${_api_file_path}"
defmodule ${_module_name}.${_resource_capitalized}Api do

  alias ${_module_name}.Runtime.${_resource_capitalized}Server

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
  def ${_action_lowercase}_${_resource_lowercase}(pid, uuid) do
    GenServer.call(pid, {:${_action_lowercase}_${_resource_lowercase}, uuid}, @timeout)
  end

EOF

  done

  printf "end\n" >> "${_api_file_path}"
}

# defmodule OnlineShop.ProductPrivateApi do
#
#   alias OnlineShop.Resources.Product
#
#   def fetch_product(attrs), do: Product.Fetch.ProductFetchContext.fetch_product(attrs)
#
#   def add_product(attrs), do: Product.Add.ProductAddContext.add_product(attrs)
#
# end
_Add_Resource_Private_API() {
  local _private_api_file_path="${_lib_path}/${_resource_lowercase}_private_api.ex"

  touch "${_private_api_file_path}"

 ### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
cat <<EOF >> "${_private_api_file_path}"
defmodule ${_module_name}.${_resource_capitalized}PrivateApi do

  alias ${_module_name}.Resources.${_resource_capitalized}

EOF

  for action in "${_actions[@]}"; do
    local _action_capitalised="${action^}"
    local _action_lowercase="${action,,}"

### DO NOT TOUCH IDENTATION AND EMPTY LINES ###
# def fetch_product(atts), do: OnlineShop.Resources.Product.Fetch.ProductContext.fetch_product(atts)
cat <<EOF >> "${_private_api_file_path}"
  def ${_action_lowercase}_${_resource_lowercase}(attrs), do: ${_resource_capitalized}.${_action_capitalised}.${_resource_capitalized}${_action_capitalised}Context.${_action_lowercase}_${_resource_lowercase}(attrs)

EOF
  done

  printf "end\n" >> "${_private_api_file_path}"
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
cat <<EOF > "${_lib_path}/runtime/watchdog.ex"
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

# defmodule OnlineShop.Runtime.Application do
#
#   # See https://hexdocs.pm/elixir/Application.html
#   # for more information on OTP Applications
#   @moduledoc false
#
#   use Application
#
#   @impl true
#   def start(_type, _args) do
#     children = [
#       { DynamicSupervisor, strategy: :one_for_one, name: OnlineShop.ProductDynamicSupervisor },
#
#       # Starts a worker by calling: OnlineShop.Worker.start_link(arg)
#       # {OnlineShop.Worker, arg}
#     ]
#
#     # See https://hexdocs.pm/elixir/Supervisor.html
#     # for other strategies and supported options
#     opts = [strategy: :one_for_one, name: OnlineShop.Supervisor]
#     Supervisor.start_link(children, opts)
#   end
#
#   def start_product_server() do
#     DynamicSupervisor.start_child(OnlineShop.ProductDynamicSupervisor, { OnlineShop.Runtime.ProductServer, nil })
#   end
#
# end
_Add_Runtime_Apllication() {

  local _application_file_path="${_lib_runtime_path}/application.ex"

  # if [ ! -f "${_application_file_path}" ]; then
  #   return
  # fi

  if ! grep -qw "${_module_name}.Runtime.Application," "${_mix_file_path}" 2&> /dev/null; then
    sed -i -e "s/${_module_name}.Application,/${_module_name}.Runtime.Application,/" "${_mix_file_path}"
  fi

  if ! grep -qw "${_module_name}.Runtime.Application," "${_application_file_path}" 2&> /dev/null; then
    sed -i -e "s/${_module_name}.Application,/${_module_name}.Runtime.Application,/" "${_application_file_path}"
  fi

  local _line="{ DynamicSupervisor, strategy: :one_for_one, name: ${_module_name}.${_resource_capitalized}DynamicSupervisor }"

  if ! grep -qw "${_line}" "${_application_file_path}" 2&> /dev/null; then
    sed -i -e "s/children = \[/children = \[\\n      ${_line},\\n/" "${_application_file_path}"
  fi

  if ! grep -qw "def start_${_resource_lowercase}_server()" "${_application_file_path}" 2&> /dev/null; then
    # sed -i -e "s/${_module_name}.Application,/${_module_name}.Runtime.Application,/" "${_application_file_path}"

    local _file=$(awk 'NR>1 && /./ { print buf; buf=rs=""} { buf=(buf rs $0); rs=RS }' "${_application_file_path}")
    echo "${_file}" > "${_application_file_path}"

cat << EOF >> "${_application_file_path}"

  def start_${_resource_lowercase}_server() do
    DynamicSupervisor.start_child(${_module_name}.${_resource_capitalized}DynamicSupervisor, { ${_module_name}.Runtime.${_resource_capitalized}Server, nil })
  end

end
EOF

  fi
}

_Add_Runtime_Server() {

  cat <<EOF > "${_lib_path}/runtime/${_resource_lowercase}_server.ex"
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

  def handle_call({:fetch_${_resource_lowercase}, uuid}, _from, {state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}.${_resource_capitalized}PrivateApi.fetch_${_resource_lowercase}(uuid)
    { :reply, result, {state, watcher} }
  end

  def handle_call({:add_${_resource_lowercase}, data}, _from, {state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}.${_resource_capitalized}PrivateApi.add_${_resource_lowercase}(data)
    { :reply, result, {state, watcher} }
  end

  def handle_call({:modify_${_resource_lowercase}, data}, _from, {state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}.${_resource_capitalized}PrivateApi.modify_${_resource_lowercase}(data)
    { :reply, result, {state, watcher} }
  end

  def handle_call({:remove_${_resource_lowercase}, uuid}, _from, {state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}.${_resource_capitalized}PrivateApi.remove_${_resource_lowercase}(uuid)
    { :reply, result, {state, watcher} }
  end

end
EOF
}

_Add_Resource() {

  local resources_path="${_lib_path}/resources"

  local _resource_path="${resources_path}/${_resource_lowercase}"
  # local _action_path="${_resource_path}/action_name"

  mkdir -p "${_resource_path}/fetch"
  mkdir -p "${_resource_path}/add"
  mkdir -p "${_resource_path}/modify"
  mkdir -p "${_resource_path}/remove"

cat <<EOF > "${_resource_path}/fetch/${_resource_lowercase}_context.ex"
defmodule ${_module_name}.Resources.${_resource_capitalized}.Fetch.${_resource_capitalized}Context do

  ### THIS IS JUST AN EXAMPLE CONTEXT FOR A RESOURCE ACTION ###
  # Online Shop APP example: OnlineShop.Resources.Product.Fetch

  def fetch_${_resource_lowercase}(uuid) do
    # your logic goes here...
    uuid
  end
end
EOF

cat <<EOF > "${_resource_path}/add/${_resource_lowercase}_context.ex"
defmodule ${_module_name}.Resources.${_resource_capitalized}.Add.${_resource_capitalized}AddContext do

  ### THIS IS JUST AN EXAMPLE CONTEXT FOR A RESOURCE ACTION ###
  # Online Shop APP example: OnlineShop.Resources.Product.Add

  def add_${_resource_lowercase}(data) do
    # your logic goes here...
    data
  end
end
EOF

cat <<EOF > "${_resource_path}/modify/${_resource_lowercase}_context.ex"
defmodule ${_module_name}.Resources.${_resource_capitalized}.Modify.${_resource_capitalized}ModifyContext do

  ### THIS IS JUST AN EXAMPLE CONTEXT FOR A RESOURCE ACTION ###
  # Online Shop APP example: OnlineShop.Resources.Product.Modify

  def modify_${_resource_lowercase}(data) do
    # your logic goes here...
    data
  end
end
EOF

cat <<EOF > "${_resource_path}/remove/${_resource_lowercase}_context.ex"
defmodule ${_module_name}.Resources.${_resource_capitalized}.Remove.${_resource_capitalized}Context do

  ### THIS IS JUST AN EXAMPLE CONTEXT FOR A RESOURCE ACTION ###
  # Online Shop APP example: OnlineShop.Resources.Product.Remove

  def remove_${_resource_lowercase}(uuid) do
    # your logic goes here...
    uuid
  end
end
EOF

cat <<EOF > "${_resource_path}/${_resource_lowercase}_contract_v1.ex"
defmodule ${_module_name}.Resources.${_resource_capitalized}.${_resource_capitalized}ContractV1 do

  ### THIS IS JUST AN EXAMPLE CONTRACT ###
  # Online Shop App example: OnlineShop.Resources.Product.ProductContractV1

  @enforce_keys [:title, :since]
  defstruct [
    title: nil,
    since: nil,
  ]

end
EOF
}

Main() {
  for input in "${@}"; do
    case "${input}" in

      --add-architecture )
          shift 1
          Add_Archictecture "${@}"
        ;;
    esac
  done
}

Main "${@}"
