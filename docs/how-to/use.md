# HOW TO USE

The **Elixir Docker Dev Stack** is an wrapper around the normal tools we use for
developing in Elixir, thus we can invoke `elixir`, 'mix' and `iex` without
having them installed in our computer, and everything should work as if they
where normally installed, because throwaway docker containers will be created to
run this commands for us.

## CREATING THE HELLO APP

Following along the official [Up and Running](https://hexdocs.pm/phoenix/up_and_running.html) for the Phoenix framework.

```bash
mix phx.new hello
```

Now we need to get inside the directory for the `hello` app.

```bash
cd hello
```

Let's create the database for the `hello` app

```bash
mix ecto.create
```
> **NOTE**: Did you notice something different from your normal work-flow?

```bash
mix phx.server
```

The `hello` app is now running on http://localhost:4000.


### The Role of the Elixir Docker Dev Stack

When we run `mix phx.new hello` the **Elixir Docker Dev Stack** will handle for
us some tasks.

#### Creation of a dedicated docker network

The `hello` app will have a dedicated docker network, named `hello_network`, to
be used when communicating between the containers on the stack.

```bash
$ sudo docker network ls | grep hello_network -
c78f64609b20        hello_network       bridge              local
```

#### Creation and setup of a dedicated docker container for the app database

I have asked previously if you noticed something different in your work-flow for
when you need to run `ecto.create` after creating a new app, and if you have not
figured it out yet, is that with the **Elixir Docker Dev Stack** you don't have
to manually start or ensure that you have a database up and running, because
this is done automatically for you.

The `hello` app will have a dedicated container for the database, named
`hello_postgres`, that is created from the official docker image for Postgres.

By default the database for this container will be persisted in host in the
directory `${host_setup_dir}_${new_app_name}/${database_engine}/data`, that may
translate to something like `~/.elixir-docker-dev-stack/Developer_Acme_Elixir_Phoenix_hello/postgres/data`.

Once we run the database in a dedicated container we need to ensure that the
`hello` app is able to communicate with it, and for that we need to adjust the
`hostname:` in `config/dev.exs` to point to `hello_postgres`, instead of the
default of `localhost`. In order to save us from having to do it manually, the
**Elixir Docker Dev Stack** updates the `hello` app config for us:

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


#### Pinning the defaults

Each time we run the **Elixir Docker Dev Stack** for the `hello` app we want to
ensure that we do it exactly with the same defaults, so that we have parity in
the development work-flow across computers and developers.

To achieve this we will use a the file named `.elixir-docker-dev-stack-defaults`
in the root of the app project, that **MUST** be tracked in git.

To save us from having to create this file manually, the **Elixir Docker Dev Stack**
have created it for us when we created the `hello` app with `mix phx.new hello`.

Let's take a look to what is inside the file:

```bash
$ cat .elixir-docker-dev-stack-defaults
elixir_tag=1.8-slim
phoenix_version=1.4.3
phoenix_command=phx.server
dockerfile=debian
database_image=postgres:11-alpine
database_user=postgres
database_data_dir=/home/exadra37/.elixir-docker-stack/Developer_Acme_Elixir_Phoenix_hello/postgres/data
database_command=postgres
```

As we can see we have pinned some defaults, and the most important ones are
`elixir_tag`, that pins the docker image to be used by this app, and
`phoenix_version` that pins the Phoenix version.

So this file guarantees that the **Elixir Docker Dev Stack** always use the same
defaults for the `hello` App, unless we decide to override them on a command
invocation.


---

[<< previous](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/install.md) | [next >>](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/CONTRIBUTING.md)

[HOME](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/README.md)
