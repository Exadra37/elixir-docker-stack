# HOW TO USE



## Creating the Hello App

Following along the official [Up and Running](https://hexdocs.pm/phoenix/up_and_running.html) for the Phoenix framework.

```bash
$ mix phx.new hello
```

Now we need to get inside the directory for the `hello` app.

```bash
$ cd hello
```

Let's see the first benefit of using the **Elixir Docker Stack**:

```bash
$  cat .elixir-docker-stack-defaults
elixir_tag=1.8-slim
phoenix_version=1.4.3
phoenix_command=phx.server
dockerfile=debian
```

When we run `mix phx.new hello` the file `.elixir-docker-stack-defaults` is
created and populated with some defaults, where the most important ones are
`elixir_tag`, that pins the docker image to be used by this app, and
`phoenix_version` that pins the Phoenix version. This file guarantees that the
**Elixir Docker Stack** always use the same defaults for the `hello` App, unless
we decide to override them.

For the database is used by default the official docker image for Postgres, thus
we need to guarantee that the `hello` App is able to reach it. In order to save
us from having to do it manually, the **Elixir Docker Stack** updates the
`hello` App config for us:

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

See how the `hostname:` entry was updated from `localhost` to `hello_postgres`
in order to match the hostname for the docker container that will run the
Postgres database for the `hello` App.



---

[<< previous](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/install.md) | [next >>](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/CONTRIBUTING.md)

[HOME](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/README.md)
