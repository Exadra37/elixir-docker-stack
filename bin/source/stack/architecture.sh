#!/bin/sh

set -eu

Add_Archictecture() {

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

  _Add_API
  _Add_Runtime
  _Add_Implementation
}

_Add_API() {
  local _api_file_path="${_lib_path}/${_app_name}_api.ex"
  # local _api_file_path="${_lib_path}/runtime_api.ex"

  mv "${_lib_path}/${_app_name}.ex" "${_api_file_path}"

  # if ! grep -qw "${_module_name}Api do" "${_api_file_path}" 2&> /dev/null; then
  #   sed -i -e "s/${_module_name} do/${_module_name}Api do/" "${_api_file_path}"
  # fi

  cat <<EOF > "${_api_file_path}"
defmodule ${_module_name}Api do

  alias ${_module_name}.Runtime.Server

  @timeout 5000

  def new_dynamic_server() do
    {:ok, pid} = ${_module_name}.Runtime.Application.start_dynamic_server()
    pid
  end

  def fetch(request) do
    GenServer.call(pid, {:fetch, request}, @timeout)
  end

  def add(request) do
    GenServer.call(pid, {:add, request}, @timeout)
  end

  def modify(request) do
    GenServer.call(pid, {:modify, request}, @timeout)
  end

  def remove(request) do
    GenServer.call(pid, {:remove, request}, @timeout)
  end

end
EOF
}

_Add_Runtime() {
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

  @dynamic_supervisor_name ${_module_name}.DynamicSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ${_module_name}.Worker.start_link(arg)
      # {${_module_name}.Worker, arg}

      # The :strategy here is the one to be used by the DynamicSupervisor to
      # supervise the hangman games it will start on demand.
      { DynamicSupervisor, strategy: :one_for_one, name: @dynamic_supervisor_name },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ${_module_name}.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_dynamic_server() do
    DynamicSupervisor.start_child(@dynamic_supervisor_name, { ${_module_name}.Runtime.Server, nil })
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

  cat <<EOF > "${_lib_path}/runtime/server.ex"
defmodule ${_module_name}.Runtime.Server do

  ### THIS IS JUST AN EXAMPLE SERVER ###
  # Todo APP example: Todos.Runtime.Server

  use GenServer

  # @type t :: pid()

  @idle_timeout_milleseconds 1 * 60 * 60 * 1000 # 1 hour

  ### Runs in the Client Process

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil)
  end


  ### Runs in this Server Process

  def init(initial_state // %{}) do
    watcher = Watchdog.start(@idle_timeout_milleseconds)
    { :ok, {initial_state, watcher} }
  end

  def handle_call({:fetch, data}, _from, {_state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}PrivateApi.fetch(data)
    { :reply, {result, watcher} }
  end

  def handle_call({:add, data}, _from, {_state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}PrivateApi.add(data)
    { :reply, {result, watcher} }
  end

  def handle_call({:modify, data}, _from, {_state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}PrivateApi.modify(data)
    { :reply, {result, watcher} }
  end

  def handle_call({:remove, data}, _from, {_state, watcher}) do
    Watchdog.im_alive(watcher)
    result = ${_module_name}PrivateApi.remove(data)
    { :reply, {result, watcher} }
  end

end
EOF
}

_Add_Implementation() {

  local _impl_path="${_lib_path}/impl"

  local _resource_path="${_impl_path}/resource_name/"
  local _action_path="${_resource_path}/action_name"

  mkdir -p "${_action_path}"

cat <<EOF > "${_action_path}/context.ex"
defmodule ${_module_name}.Impl.ResourceName.ActionName.Context do

  ### THIS IS JUST AN EXAMPLE CONTEXT FOR A RESOURCE ACTION ###
  # Todo APP example: Todos.Impl.Todo.Add

  # def add() do
  def action_name() do
    # your logic goes here...
  end
end
EOF

cat <<EOF > "${_resource_path}/contract_v1.ex"
defmodule ${_module_name}.Impl.ResourceName.ContractV1 do

  ### THIS IS JUST AN EXAMPLE CONTRACT ###
  # Todo App example: Todos.Impl.Todo.ContractV1

  use Domo

  typedstruct do
    field :type, :professional | :personal
    field :title, String.t()
    field :since, NaiveDateTime.t(), default: NaiveDateTime.utc_now()
  end

  @all_types %{
    professional: "Professional",
    personal: "Personal",
  }

  @types Map.keys(@all_types)

  def default(), do: new_for!(:professional)

  def new_for!(type), do: new!(type: type, title: @all_types[type])
  def new_for!(type, title: title), do: new!(type: type, title: title)

  def types(), do: @types

  def all_types(), do: @all_types
end
EOF
}
