# ELIXIR DOCKER IMAGE


## MENU

* **The Package**
    + [Why Exists?](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/the-package/why_exists.md)
    + [What Is It?](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/the-package/what_is_it.md)
    + [When To use It?](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/the-package/when_to_use_it.md)
* **How To**
    + [Install](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/install.md)
    + [Use](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/use.md)
    + [Report an Issue](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/create_an_issue.md)
    + [Create a Branch](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/create_branches.md)
    + [Open a Merge Request](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/create_a_merge_request.md)
    + [Uninstall](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/uninstall.md)
* **Demos**
    + [Elixir - Hello World](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/demos/elixir-hello-world.md)
* **Road Map**
    + [Milestones](https://gitlab.com/exadra37-docker/elixir/elixir/milestones)
    + [Overview](https://gitlab.com/exadra37-docker/elixir/elixir/boards)
* **About**
    + [Author](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/AUTHOR.md)
    + [Contributors](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/CONTRIBUTORS.md)
    + [Contributing](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/CONTRIBUTING.md)
    + [License](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/LICENSE)

## QUICK START

### Install

Clone the project somewhere in your computer:

```bash
git clone https://gitlab.com/exadra37-docker/elixir/elixir-docker-stack.git
```

Now we need to set where you have installed the **Elixir Docker Stack**:

```bash
export ELIXIR_DOCKER_STACK_INSTALL_DIR="${PWD}/elixir-docker-stack"
```

Time to build the docker image for the **Elixir Docker Stack**:

```bash
elixir build debian
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


### Creating a New Phoenix App

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

Time to start the Phoenix server:

```bash
mix phx.server
```

The `hello` app is now running on http://localhost:4000.


## SUPPORT DEVELOPMENT

If this is useful for you, please:

* Share it on [Twitter](https://twitter.com/home?status=Base%20%23DockerImage%20for%20%23Elixir%20%23developers%20https%3A//gitlab.com/exadra37-docker/elixir/elixir%20by%20%40Exadra37.%20%23docker%20%23dockercontainers%20%23myelixirstatus) or in any other channel of your preference.
* Consider to [offer me](https://www.paypal.me/exadra37) a coffee, a beer, a dinner or any other treat 😎.


## EXPLICIT VERSIONING

This repository uses [Explicit Versioning](https://gitlab.com/exadra37-versioning/explicit-versioning) schema.


## BRANCHES

Branches are created as demonstrated [here](docs/how-to/create_branches.md).

This are the type of branches we can see at any moment in the repository:

* `master` - issues and milestones branches will be merged here. Don't use it in
              production.
* `last-stable-release` - matches the last stable tag created. Useful for
                           automation tools. Doesn't guarantee backwards
                           compatibility.
* `4-fix-some-bug` - each issue will have is own branch for development.
* `milestone-12_add-some-new-feature` - all Milestone issues will start, tracked and merged
                             here.

Only `master` and `last-stable-release` branches will be permanent ones in the
repository and all other ones will be removed once they are merged.


## DISCLAIMER

I code for passion and when coding I like to do as it pleases me...

You know I do this in my free time, thus I want to have fun and enjoy it ;).

Professionally I will do it as per company guidelines and standards.
