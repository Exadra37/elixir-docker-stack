#!/bin/sh

set -eu

main()
{
  ##############################################################################
  # VARS
  ##############################################################################

    local erlang_lib_dir=/usr/local/lib/erlang/lib

    local erlang_wx=$( find ${erlang_lib_dir}  -name 'wx-*' )

    local erlang_wx_version=${erlang_wx##*/}

    local erlang_wx_dir=/usr/lib/erlang/lib/"${erlang_wx_version}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n>>> FIXING OBSERVER DEPENDENCIES FOR ERLANG WX VERSION: ${erlang_wx_version} <<< \n"

    if [ -d "${erlang_wx_dir}" ]; then
      # https://elixirforum.com/t/observer-start-is-not-working-on-ubuntu/6018/21?u=exadra37
      rm -rvf "${erlang_lib_dir}/${erlang_wx_version}"
      ln -s "${erlang_wx_dir}" "${erlang_lib_dir}"
    fi
}

main
