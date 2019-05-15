# TODO

## FEATURES

* command to start database
    $ eds up database
    $ eds -it up database
* load `.env.app-docker-container` by `MIX_ENV`, thus maybe
  have a prefix or suffix in the file with mix env value.
* add support to run from the host the `npm` commands inside the Elixir Docker Stack container.

## BUGS

* fix database hostname when using `--db` or using the command?

### Elixir docker stack defaults file

When in any app always load the file from the root of the project.

### Container Hostname

When in any app we use the container name and hostname from the root of the project. 

We cannot have nodes with `-` in the name, thus I need to fix the docker container hostnames created from the folder name to not have the `-`:

```
╭─exadra37@thinkpap-l460 ~/Developer/Learning/Elixir/PragDave/elixir-for-programmers/.local/e4p-code  ‹130-hangman-server-complete*› 
╰─➤  iex --sname two                                                                                                                            130 ↵
[sudo] password for exadra37: 
Erlang/OTP 20 [erts-9.3.3.12] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false]

Interactive Elixir (1.5.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(two@e4p-code)1> Node.connect :one@e4p-code
** (CompileError) iex:1: undefined function code/0
    (stdlib) lists.erl:1354: :lists.mapfoldl/3
    (stdlib) lists.erl:1355: :lists.mapfoldl/3

```
