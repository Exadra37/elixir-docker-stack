#!/bin/sh

set -eu

Add_Archictecture() {

  local _command=${1? Missing command to create the resource and actions, e.g. foo:fetch,add,mofify,remove }

  # from foo:fetch,add we get: foo
  local _resource=${1%%:*}

  # from foo:fetch,add we get: fetch,add
  local _actions=${1##*:}

  local _resource_capitalized="${1}"
  local _resource_lowercase="${2}"

  local _mix_file_path="${APP_PATH}/mix.exs"

  # From defmodule HelloWorld.Mixproject do we get: HelloWorld.Mixproject
  local _first_line="$(cat ${_mix_file_path} | head -n 1 | awk '{print $2}')"

  # From HelloWorld.Mixproject we get: HelloWorld
  local _module_name="${_first_line%.*}"

  # From ~/some/absolute/path/hello_world we get: hello_world
  local _app_name="${APP_PATH##*/}"

  # From mix phx_new hello_world we get: hello_world/lib/hello_world
  local _lib_path="${APP_PATH}/lib"
  local _lib_app_path="${APP_PATH}/lib/${_app_name}"

  _Add_API "Foo" "foo"
  _Add_Runtime "Foo" "foo"
  _Add_Resource "Foo" "foo"
}

_Add_API() {
  local _resource_capitalized="${1}"
  local _resource_lowercase="${2}"

  local _api_file_path="${_lib_path}/${_resource_lowercase}_api.ex"
  local _private_api_file_path="${_lib_path}/${_resource_lowercase}_private_api.ex"
  # local _api_file_path="${_lib_path}/runtime_api.ex"

  mv "${_lib_path}/${_app_name}.ex" "${_api_file_path}"

  # if ! grep -qw "${_module_name}Api do" "${_api_file_path}" 2&> /dev/null; then
  #   sed -i -e "s/${_module_name} do/${_module_name}Api do/" "${_api_file_path}"
  # fi

  cat <<EOF > "${_private_api_file_path}"
defmodule ${_module_name}.${_resource_capitalized}PrivateApi do

  ### THIS IS JUST AN EXAMPLE SERVER ###
  # Online Shop APP example: OnlineShopPrivateApi

  # def fetch_product(uuid), do: OnlineShop.Resources.Product.Fetch.ProductContext.fetch_product(uuid)
  def fetch_${_resource_lowercase}(uuid), do: ${_module_name}.Resources.${_resource_capitalized}.Fetch.${_resource_capitalized}Context.fetch_${_resource_lowercase}(uuid)

  # def add_product(data), do: OnlineShop.Resources.Product.Add.ProductContext.add_product(data)
  def add_${_resource_lowercase}(data), do: ${_module_name}.Resources.${_resource_capitalized}.Add.${_resource_capitalized}Context.add_${_resource_lowercase}(data)

  # def modify_product(data), do: OnlineShop.Resources.Product.Modify.ProductContext.modify_product(data)
  def modify_${_resource_lowercase}(data), do: ${_module_name}.Resources.${_resource_capitalized}.Modify.${_resource_capitalized}Context.modify_${_resource_lowercase}(data)

  # def remove_product(uuid), do: OnlineShop.Resources.Product.Remove.ProductContext.remove_product(uuid)
  def remove_${_resource_lowercase}(uuid), do: ${_module_name}.Resources.${_resource_capitalized}.Remove.${_resource_capitalized}Context.remove_${_resource_lowercase}(uuid)

end

EOF

  cat <<EOF > "${_api_file_path}"
defmodule ${_module_name}.${_resource_capitalized}Api do

  ### THIS IS JUST AN EXAMPLE API ###
  # Online Shop APP example: OnlineShopApi

  alias ${_module_name}.Runtime.${_resource_capitalized}Server

  @timeout 5000

  def new_${_resource_lowercase}_server() do
    {:ok, pid} = ${_module_name}.Runtime.Application.start_${_resource_lowercase}_server()
    pid
  end

  def fetch_${_resource_lowercase}(pid, uuid) do
    GenServer.call(pid, {:fetch_${_resource_lowercase}, uuid}, @timeout)
  end

  def add_${_resource_lowercase}(pid, data) do
    GenServer.call(pid, {:add_${_resource_lowercase}, data}, @timeout)
  end

  def modify_${_resource_lowercase}(pid, data) do
    GenServer.call(pid, {:modify_${_resource_lowercase}, data}, @timeout)
  end

  def remove_${_resource_lowercase}(pid, uuid) do
    GenServer.call(pid, {:remove_${_resource_lowercase}, uuid}, @timeout)
  end

end
EOF
}

_Add_Runtime() {
  local _resource_capitalized="${1}"
  local _resource_lowercase="${2}"

  local _application_file_path="${_lib_app_path}/application.ex"

  if [ ! -f "${_application_file_path}" ]; then
    return
  fi

  if ! grep -qw "${_module_name}.Runtime.Application," "${_mix_file_path}" 2&> /dev/null; then
    sed -i -e "s/${_module_name}.Application,/${_module_name}.Runtime.Application,/" "${_mix_file_path}"
  fi

  # if ! grep -qw "${_module_name}.Runtime.Application do" "${_application_file_path}" 2&> /dev/null; then
  #   sed -i -e "s/${_module_name}.Application do/${_module_name}.Runtime.Application do/" "${_application_file_path}"
  # fi

  mv "${_lib_app_path}" "${_lib_path}/runtime"


  cat <<EOF > "${_lib_path}/runtime/application.ex"
defmodule ${_module_name}.Runtime.Application do

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ${_module_name}.Worker.start_link(arg)
      # {${_module_name}.Worker, arg}

      # The :strategy here is the one to be used by the DynamicSupervisor to
      # supervise the server it will start on demand.
      { DynamicSupervisor, strategy: :one_for_one, name: ${_module_name}.${_resource_capitalized}DynamicSupervisor },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ${_module_name}.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_${_resource_lowercase}_server() do
    DynamicSupervisor.start_child(${_module_name}.${_resource_capitalized}DynamicSupervisor, { ${_module_name}.Runtime.${_resource_capitalized}Server, nil })
  end

end

EOF

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

  cat <<EOF > "${_lib_path}/runtime/${_resource_lowercase}_server.ex"
defmodule ${_module_name}.Runtime.${_resource_capitalized}Server do

  ### THIS IS JUST AN EXAMPLE SERVER ###
  # Online Shop APP example: OnlineShop.Runtime.ProductServer

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

  local _resource_capitalized="${1}"
  local _resource_lowercase="${2}"

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
