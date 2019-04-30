# ELIXIR DOCKER STACK

The **Elixir Docker Stack** is a wrapper around the normal tools we use for
developing in Elixir, thus we can invoke `elixir`, `mix`, `iex` and other tools
without having them installed in our computer, and everything should work as if
they where normally installed, because throwaway docker containers will be
created to run this commands for us.


# MENU

* **QUICK START**
    + [Install](#install)
    + [Creating a New Phoenix App](#creating-a-new-phoenix-app)
    + [Creating a New App With a Specific Version of Elixir and Phoenix](#creating-a-new-app-with-a-specific-version-of-elixir-and-phoenix)
* **ELIXIR DOCKER STACK EXPLAINED**
    + [Why Exists?](#why-exists)
    + [What Is It?](#what-is-it)
    + [What is Included?](#what-is-included)
    + [What it does for us under the hood?](#what-it-does-for-us-under-the-hood)
* **HOW TO**
    + [Install](#install)
    + [Use](#how-to-use)
        - [EDS](#eds-elixir-docker-stack)
        - [Elixir](#elixir)
        - [Mix](#mix)
        - [IEx](#iex)
        - [Observer](#observer)
            + [Graphical User Interface](#graphical-user-interface)
            + [Htop](#htop)
            + [Shell](#shell)
    + [Contribute](./CONTRIBUTING.md)
        - [Report an Issue](./CONTRIBUTING.md#with-a-new-issue)
        - [Open a Merge Request](./CONTRIBUTING.md#merge-request-guidelines)
    + [Uninstall](#uninstall)
* **ROAD MAP**
    + [Milestones](https://gitlab.com/exadra37-docker/elixir/elixir/milestones)
    + [Overview](https://gitlab.com/exadra37-docker/elixir/elixir/boards)
* **ABOUT**
    + [Author](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/AUTHOR.md)
    + [Contributors](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/CONTRIBUTORS.md)
    + [License](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/LICENSE)


# QUICK START

## Install

Clone the project somewhere in your computer:

```bash
git clone https://gitlab.com/exadra37-docker/elixir/elixir-docker-stack.git ~
```

Next we need to set where you have installed the **Elixir Docker Stack**:

```bash
export ELIXIR_DOCKER_STACK_INSTALL_DIR="${PWD}/elixir-docker-stack"
```
> **NOTE:**
>
>   * The `export` command assumes you are not inside the folder `elixir-docker-stack`.

And we also need to export to our `PATH`, the `bin` folder for the **Elixir Docker Stack**:

```bash
export PATH="${ELIXIR_DOCKER_STACK_INSTALL_DIR}/bin:${PATH}"
```
> **NOTE**:
>
>   * If you already have Elixir installed, the `bin` folder for the **Elixir
>     Docker Stack** will be the first in the `$PATH`, thus when you invoke
>     `elixir`, `mix`, `iex`, `erl`, `rebar` or `rebar3` you are not using the
>     ones you already have installed, instead you are running the
>     **Elixir Docker Stack** ones.

Please bear in mind that once we are using `export` the **Elixir Docker Stack**
only works on this current shell session, if you open another window or tab you
need to repeat the `export` commands.

For a **permanent installation** add to your shell the `export` commands. In a
bash shell the file to add them is located at `~/.bashrc`.

Now is time to build the docker image for the **Elixir Docker Stack**:

```bash
eds build debian
```

Let's do some smoke tests:

```bash
$ elixir --version
Erlang/OTP 21 [erts-10.3.4] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Elixir 1.8.1 (compiled with Erlang/OTP 21)

$ mix phx.new --version
Phoenix v1.4.3
```

Seems that we have a working **Elixir Docker Stack** :).

[Menu](#menu)


## Creating a New Phoenix App

Following along the official [Up and Running](https://hexdocs.pm/phoenix/up_and_running.html) for the Phoenix framework.

Creating a new Phoenix app:

```bash
mix phx.new hello
```

Now we need to get inside the directory for the `hello` app:

```bash
cd hello
```

Let's create the database for the `hello` app:

```bash
mix ecto.create
```
> **NOTE**: Did you notice something different from your normal work-flow?


Time to start the Phoenix server:

```bash
mix phx.server
```

The `hello` app is now running on http://localhost:4000.

[Menu](#menu)


## Creating a New App With a Specific Version of Elixir and Phoenix

Let's imagine that you want to quickly try an old app that is stuck on Elixir
version `1.4` and Phoenix version `1.3.4`, all you need to do is to...

Let's imagine that you bought a book and discovered that the code examples on it
only work on Elixir `1.4` and Phoenix `1.3.4`, and instead of figuring out how
to make the code work for the current versions, you can quickly create a throwaway
docker stack for it:

```bash
mix --elixir-version 1.4.5 --phoenix-version 1.3.4 phx.new myapp
```

Lets check that we have the new app working with the version we required for
Elixir:

```bash
$ cd myapp && elixir --version
Erlang/OTP 19 [erts-8.3.5.7] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false]

Elixir 1.4.5
```

and for Phoenix the version is:

```bash
mix phx.new --version
Phoenix v1.3.4
```

If you are curious about the docker image we have created, check it with:

```bash
$ sudo docker image ls | head -2
REPOSITORY                       TAG                       IMAGE ID            CREATED             SIZE
exadra37/elixir-phoenix          1.4.5-1.3.4-debian        6fba76ed6d7c        5 minutes ago       969MB
```

Finally lets confirm that we have the defaults pinned:

```bash
$ cat .elixir-docker-stack-defaults
elixir_version=1.4.5
phoenix_version=1.3.4
phoenix_command=phx.server
dockerfile=debian
database_image=postgres:11-alpine
database_user=postgres
database_data_dir=/home/exadra37/.elixir-docker-stack/Developer_Acme_Elixir_Phoenix_myapp/postgres/data
database_command=postgres
```

Now you can follow the same procedures of the `hello` app to have `myapp` up and
running on http://localhost:4000.

[Menu](#menu)


## Getting Help

To get help for the **Elixir Docker Stack** itself you just do:

```bash
$ eds --help

ELIXIR DOCKER STACK (EDS)

A docker developemnt stack that includes Elixir, Phoenix, Erlang, Observer and Postgres.


ELIXIR DOCKER STACK USAGE:

  eds [options] [command] [args]


DOCKER STACK OPTIONS:

  -d, --detached            Run the docker container detached from the terminal.

  --db, --database          Starts the container with the Postgres database up.


  --di, --database-image    The dockerfile to run the database container.
                            Defaults to: postgres:11-alpine
                              $ eds --database-image postgres:10 --db up

  --df, --dockerfile        The dockerfile to run a container.
                            Defaults to: debian
                              $ eds --dockerfile alpine up
                              $ eds --dockerfile debian.esl up
                              $ eds --dockerfile debian.slim up
                              $ eds --dockerfile debian.git.branch up
                              $ eds --dockerfile debian.git.release up

  -e, --env                 Add an environment variable to the running command.
                            Instead of PORT=4040 mix phx.server, do:
                              $ mix --env PORT=4040 phx.server

  --ev, --elixir-version    The Elixir version to be used for the docker tag,
                            Defaults to the latest Elixir version: 1.8
                              $ eds --elixir-version 1.3.4 up

  -h, --help                Shows the help for the Elixir CLI and Stack.
                              $ eds -h
                              $ eds --help
                              $ eds --help stack

  -it, --interactive-tty    Run the docker container attached to the terminal.
                              $ eds -it up

  --mix-env                 Sets the MIX_ENV var in the container.
                            Defaults to dev.
                              $ mix --mix-env test ecto.create

  -p, --publish             Map the host ports to the docker container ports.
                            Defaults to: 4000:4000 .
                              $ eds --publish 8000:4000 up

  --pv, --phoenix-version   The Phoenix version to be installed.
                            Defaults to the last release, eg: 1.4.3 .
                              $ eds --phoenix-version 1.3.4 up

  -u, --user                The user we want to run inside the container,
                            Defaults to user, eg: elixir .
                              $ eds --user root shell

  --verbose <level>         Enables verbose output for the docker stack.
                            Defaults to level 0, and can go until level 4.
                              $ eds --verbose 1 up
                              $ eds --verbose 2 shell
                              $ eds --verbose 3 observer
                              $ eds --verbose 4 build

  --wda, --wait-dummy-app   Seconds to wait for the app dummy container to be ready.
                            Defaults to 1 second.
                              $ eds --wait-dummy-app 3 up

  --wd, --wait-database     Seconds to wait for the database is up and running.
                            Defaults to 5 seconds.
                              $ eds --wait-database 10 new-database myapp_test

ELIXIR DOCKER STACK (EDS) COMMANDS:

  <no-command>    Runs Elixir inside the container as it would in the host.
                    $ elixir --help

  build           Builds the docker image for the given dodkerfile.
                  Defaults to build from: debian .
                    $ eds build
                    $ eds build alpine
                    $ eds build debian.esl
                    $ eds build debian.git.branch
                    $ eds build debian.git.release

  container-logs  Shows a tail -f of the container logs.
                    $ eds container-logs

  down            Stops and removes the running containers.
                    $ eds down

  new-database    Creates a new database.
                  Defaults to the current folder name with suffix "_dev".
                    $ eds new-database
                    $ eds new-database acme

  pgcli           A better shell for Postgres, includes auto-completion.
                    $ eds pgcli [options] [args]

  observer        Starts the Observer GUI from an IEx shell.
                    $ eds observer

  observer htop   Allows to start from IEx the Observer CLI(like Linux HTOP).
                    $ eds observer htop

  observer shell  Starts a shell inside the Observer container.
                  Default shell: zsh
                    $ eds observer shell
                    $ eds --user root observer shell

  up              Starts the Elixir Docker Stack.
                    $ eds up
                    $ eds --db up
                    $ eds --dockerfile alpine up
                    $ eds -it --publish 8000:4000 up
                    $ eds --elixir-version 1.3 --phoenix-version 1.3.4 --db up

  shell           A shell inside the container for the Elixir Docker Stack.
                    $ eds shell
                    $ eds --user root shell
```

To get help for options and commands from the **Elixir Docker Stack**, that can
be used when invoking the official tools, like `elixir`, `mix`, etc., you must
ask explicitly with an argument passed to the help flag `-h stack`:

```bash
$ elixir --help stack

ELIXIR ON THE ELIXIR DOCKER STACK

A docker development stack that includes Elixir, Phoenix, Erlang, Observer and Postgres.


ELIXIR USAGE:

  elixir [docker-stack-options] [elixir-options] [.exs file] [data]


DOCKER STACK OPTIONS:

  -d, --detached            Run the docker container detached from the terminal.

  --db, --database          Starts the container with the Postgres database up.


  --di, --database-image    The dockerfile to run the database container.
                            Defaults to: postgres:11-alpine
                              $ elixir --database-image postgres:10 --db up

  --df, --dockerfile        The dockerfile to run a container.
                            Defaults to: debian
                              $ elixir --dockerfile alpine up
                              $ elixir --dockerfile debian.esl up
                              $ elixir --dockerfile debian.slim up
                              $ elixir --dockerfile debian.git.branch up
                              $ elixir --dockerfile debian.git.release up

  -e, --env                 Add an environment variable to the running command.
                            Instead of PORT=4040 mix phx.server, do:
                              $ mix --env PORT=4040 phx.server

  --ev, --elixir-version    The Elixir version to be used for the docker tag,
                            Defaults to the latest Elixir version: 1.8
                              $ elixir --elixir-version 1.3.4 up

  -h, --help                Shows the help for the Elixir CLI and Stack.
                              $ elixir -h
                              $ elixir --help
                              $ elixir --help stack

  -it, --interactive-tty    Run the docker container attached to the terminal.
                              $ elixir -it up

  --mix-env                 Sets the MIX_ENV var in the container.
                            Defaults to dev.
                              $ mix --mix-env test ecto.create

  -p, --publish             Map the host ports to the docker container ports.
                            Defaults to: 4000:4000 .
                              $ elixir --publish 8000:4000 up

  --pv, --phoenix-version   The Phoenix version to be installed.
                            Defaults to the last release, eg: 1.4.3 .
                              $ elixir --phoenix-version 1.3.4 up

  -u, --user                The user we want to run inside the container,
                            Defaults to user, eg: elixir .
                              $ elixir --user root shell

  --verbose <level>         Enables verbose output for the docker stack.
                            Defaults to level 0, and can go until level 4.
                              $ elixir --verbose 1 up
                              $ elixir --verbose 2 shell
                              $ elixir --verbose 3 observer
                              $ elixir --verbose 4 build

  --wda, --wait-dummy-app   Seconds to wait for the app dummy container to be ready.
                            Defaults to 1 second.
                              $ elixir --wait-dummy-app 3 up

  --wd, --wait-database     Seconds to wait for the database is up and running.
                            Defaults to 5 seconds.
                              $ elixir --wait-database 10 new-database myapp_test

ELIXIR DOCKER STACK COMMANDS:

The Elixir Docker Stack does not provide any specific commands to use in
conjunction with the official `elixir` CLI tool.
```

As you can see we can use the same docker stack options available in `eds` with
the official `elixir` tool.

So if we try to get help without using the argument `stack` for the help flag,
we get the usual output:

```bash
$ elixir --help
Usage: elixir [options] [.exs file] [data]

  -e COMMAND                  Evaluates the given command (*)
  -r FILE                     Requires the given files/patterns (*)
  -S SCRIPT                   Finds and executes the given script in PATH
  -pr FILE                    Requires the given files/patterns in parallel (*)
  -pa PATH                    Prepends the given path to Erlang code path (*)
  -pz PATH                    Appends the given path to Erlang code path (*)

  --app APP                   Starts the given app and its dependencies (*)
  --cookie COOKIE             Sets a cookie for this distributed node
  --detached                  Starts the Erlang VM detached from console
  --erl SWITCHES              Switches to be passed down to Erlang (*)
  --help, -h                  Prints this message and exits
  --hidden                    Makes a hidden node
  --logger-otp-reports BOOL   Enables or disables OTP reporting
  --logger-sasl-reports BOOL  Enables or disables SASL reporting
  --name NAME                 Makes and assigns a name to the distributed node
  --no-halt                   Does not halt the Erlang VM after execution
  --sname NAME                Makes and assigns a short name to the distributed node
  --version, -v               Prints Elixir version and exits
  --werl                      Uses Erlang's Windows shell GUI (Windows only)

** Options marked with (*) can be given more than once
** Options given after the .exs file or -- are passed down to the executed code
** Options can be passed to the Erlang runtime using ELIXIR_ERL_OPTIONS or --erl
```

To summarize any of the official tools belonging to Elixir and Erlang will
behave exactly as you are used to when invoking the help for them.

[Menu](#menu)


# ELIXIR DOCKER STACK EXPLAINED

This section will try to answer some questions you may have regarding the
**Elixir Docker Stack**, and to explain how some details are handled for us, to
free up the developer from manually set them.

## Why Exists?

Initially was supposed to be only a simple docker image for Elixir with my
favourite shell and with a unprivileged user inside the docker container, but
end-up to grow up to be a full development stack for Elixir.

I am a huge fan of using docker work-flow in development, and some of the
reasons for it are:

* Same development environment across computers and developers working on the
  same project.
* I can run as many versions as I want of the tools I use, and throw away them
  when I am done, without impacting my operating system, and yes I know I can
  use version managers to achieve the same.
* A cleaner operating system, once all my development tooling is running in
  docker containers, thus I can upgrade my OS at any-time with less fuss.
* I can obtain a shell inside a docker container, install as many stuff I want
  to try, without risking to mess-up, break the operating system, or leave
  left-overs after I uninstall them(remember docker containers are destroy on
  exit).
* More secure, once docker acts like a "sandbox", and yes I know that docker
  have suffered from "sandbox" escape in the past.

[Menu](#menu)


## What is It?

The **Elixir Docker Stack** is a set of tools needed for a normal development
work-flow with Elixir.

The goal is to be able to use this tools as if they are installed normally in
the operating system, or if the developer prefers to use them from a shell
inside the docker container.

All docker containers created are ephemeral, thus they are destroyed when the
command we executed inside them returns. To keep state we map folders from the
host computer to inside the docker container.

[Menu](#menu)


## What is Included?

The software included:

* Elixir
* Phoenix
* Erlang
* Postgres

The most useful tools included in the bin path:

* elixir
* mix
* erl
* rebar
* rebar3
* observer
* pgcli

[Menu](#menu)


## What it does for us under the hood?

When we run `mix phx.new hello` the **Elixir Docker Stack** will handle for
us some tasks, like creating the docker network, starting the database server,
pinning the defaults and updating the app configuration.

[Menu](#menu)

### Creation of a dedicated docker network

The `hello` app will have a dedicated docker network, named `hello_network`, to
be used when communicating between the containers on the stack.

```bash
$ sudo docker network ls | grep hello_network -
c78f64609b20        hello_network       bridge              local
```

[Menu](#menu)

### Creation and setup of a dedicated docker container for the app database

I have asked previously if you noticed something different in your work-flow for
when you need to run `ecto.create` after creating a new app, and if you have not
figured it out yet, is that with the **Elixir Docker Stack** you don't have
to manually start or ensure that you have a database up and running, because
this is done automatically for you.

The `hello` app will have a dedicated container for the database, named
`hello_postgres`, that is created from the official docker image for Postgres.

By default the database for this container will be persisted in host in the
directory `${host_setup_dir}_${new_app_name}/${database_engine}/data`, that may
translate to something like `~/.elixir-docker-stack/Developer_Acme_Elixir_Phoenix_hello/postgres/data`.

Once we run the database in a dedicated container we need to ensure that the
`hello` app is able to communicate with it, and for that we need to adjust the
`hostname:` in `config/dev.exs` to point to `hello_postgres`, instead of the
default of `localhost`. In order to save us from having to do it manually, the
**Elixir Docker Stack** updates the `hello` app config for us:

```bash
$ cat config/dev.exs | tail -8

# Configure your database
config :hello, Hello.Repo,
  username: "postgres",
  password: "postgres",
  database: "hello_dev",
  hostname: "hello_postgres",
  pool_size: 10
```

Now we have the `hostname:` entry updated from `localhost` to `hello_postgres`.

Docker containers sharing the same network can communicate between them by using
the container name as a DNS resolver inside the network. So in this case we use
for the `hostname:` the value of `hello_postgres`, that is the name used for the
database container.

[Menu](#menu)

### Pinning the defaults

Each time we run the **Elixir Docker Stack** for the `hello` app we want to
ensure that we do it exactly with the same defaults, so that we have parity in
the development work-flow across computers and developers.

To achieve this we will use a the file named `.elixir-docker-stack-defaults`
in the root of the app project, that **MUST** be tracked in git.

To save us from having to create this file manually, the **Elixir Docker Stack**
have created it for us when we created the `hello` app with `mix phx.new hello`.

Let's take a look to what is inside the file:

```bash
$ cat .elixir-docker-stack-defaults
elixir_version=1.8
phoenix_version=1.4.3
phoenix_command=phx.server
dockerfile=debian
database_image=postgres:11-alpine
database_user=postgres
database_data_dir=/home/exadra37/.elixir-docker-stack/Developer_Acme_Elixir_Phoenix_hello/postgres/data
database_command=postgres
```

As we can see we have pinned some defaults, and the most important ones are
`elixir_version`, that pins the docker image to be used by this app, and
`phoenix_version` that pins the Phoenix version.

So this file guarantees that the **Elixir Docker Stack** always use the same
defaults for the `hello` App, unless we decide to override them on a command
invocation.

[Menu](#menu)


# HOW TO USE

## EDS (Elixir Docker Stack)

This is the main tool for the **Elixir Docker Stack**, that builds, starts,
stops and destroys all docker containers used in the stack.

See the help for all you can do with it:

```bash
eds --help
```

[Menu](#menu)

## Elixir

The elixir CLI tool will be used as you are used to, but it responds to some
additional options and commands, and you can view all, with examples, by asking
for help:

```bash
elixir --help stack
```

All this options and arguments are used to handle the docker stack and to make
some tasks easier for us.

[Menu](#menu)

## Mix

The mix CLI tool works as usual but accepts some options that are specific to
the **Elixir Docker Stack**.

[Menu](#menu)

### The `--mix-env` option

From the name should be pretty options what is for...

Use it like:

```bash
mix --mix-env test ecto.create
```

[Menu](#menu)

### The `--pv, --phoenix-version` option

When creating a new app with Mix, the latest Phoenix will be used, but we can
use this option to create the app with an older version of Phoenix.

Use like this:

```bash
mix --phoenix-version 1.3.4 php.new my_app_name
```

[Menu](#menu)

### The `--ev, --elixir-version` option

For the same reasons that we may want to use `--phoenix-version` we may also
want to specify the Elixir version to use, and for that we need to use the
`--elixir-version` option, that will be used to construct the tag to pull the
official docker image for Elixir. You can see all available tags in the
Docker Hub [Elixir repository](https://hub.docker.com/_/elixir?tab=tags).

By default the **Elixir Docker Stack** defaults to a specific major version of
Elixir, eg: `1.8`, that is a full Debian release, that makes the docker images
substantially bigger then `1.8-slim` or `1.8-alpine` tags, but comes with the
build dependencies that are necessary for some dependencies, that need to use
`make` and build some C libraries.

So if we need to create a new Phoenix app that uses the latest version available
for Elixir `1.7.*`, then we type:

```bash
mix --elixir-version 1.7 phx.new my_app_name
```

or for a Slim Debian release:

```bash
mix --elixir-version 1.7-slim phx.new my_app_name
```

But if you need to pin to the exact Elixir version, then:

```bash
mix --elixir-version 1.7.1 phx.new my_app_name
```

[Menu](#menu)

## IEx

Just use as usual:

```bash
iex
```

or

```bash
iex -S mix
```

or any other command you are used to run...

> **NOTE**:
>
>   Observer is usually broken in Debian Slim or Alpine flavours. This is an
>   issue that derives from the official docker image for Elixir, thus use only
>   the default Debian docker image if you need to use Observe, or in
>   alternative see the next section to use the custom command `eds observer`.

[Menu](#menu)

## Observer

Observer runs in a different docker image from our app, thus in order to use the
**Elixir Docker Stack** command to start the Observer you need to have already
the app up and running, otherwise a fatal error will be raised.

[Menu](#menu)

### Graphical User Interface

To run it, just type:

```bash
eds observer
```

This command will fire up an `IEx` session and start the Observer for us, and
once it also connects us to the node where our App is running we just need to
select if from the `Nodes` menu.

[Menu](#menu)

### HTOP

So if you already know HTOP for Linux, than you may have already an idea of
what is expecting you ;).

To use this command the app needs to have installed the `{:observer_cli, "~> 1.4"}`
dependency.

To run, just type:

```bash
eds observer htop
```

This command will fire up a session in the `IEx` shell for the app, and we just
need to type in the IEx shell:

```bash
iex> :observer_cli.start
```

Enjoy your [HTOP](https://github.com/zhongwencool/observer_cli) for Elixir :)

[Menu](#menu)

### Shell

As already mentioned the Observer run in a different container from our app,
thus if for some reason you need to access the bash shell for some debugging or
to fire up an IEx shell, you just need to run a bash shell in the Observer
container.

Just type:

```bash
eds observer shell
```

or for root access:

```bash
eds --user root observer shell
```

[Menu](#menu)


# SUPPORT DEVELOPMENT

If this is useful for you, please:

* Share it on [Twitter](https://twitter.com/home?status=Base%20%23DockerImage%20for%20%23Elixir%20%23developers%20https%3A//gitlab.com/exadra37-docker/elixir/elixir%20by%20%40Exadra37.%20%23docker%20%23dockercontainers%20%23myelixirstatus) or in any other channel of your preference.
* Consider to [offer me](https://www.paypal.me/exadra37) a coffee, a beer, a dinner or any other treat 😎.

[Menu](#menu)


# EXPLICIT VERSIONING

This repository uses [Explicit Versioning](https://gitlab.com/exadra37-versioning/explicit-versioning) schema.

[Menu](#menu)


# DISCLAIMER

I code for passion and when coding I like to do as it pleases me...

You know I do this in my free time, thus I want to have fun and enjoy it ;).

Professionally I will do it as per company guidelines and standards.

[Menu](#menu)
