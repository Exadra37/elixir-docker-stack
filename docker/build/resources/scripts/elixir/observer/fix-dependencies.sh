#!/bin/sh

set -eu

Main()
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

    # apt install -y --no-install-recommends \
    #   libcanberra-gtk-module \
    #   libcanberra-gtk3-module \
    #   libwxgtk3.0

    # runtimeDeps='
    #   libodbc1
    #   libssl1.1
    #   libsctp1
    #   libwxgtk3.0
    # '
    # buildDeps='
    #   autoconf
    #   dpkg-dev
    #   gcc
    #   g++
    #   make
    #   libncurses-dev
    #   unixodbc-dev
    #   libssl-dev
    #   libsctp-dev
    #   libwxgtk3.0-dev
    # '

    # apt install -y --no-install-recommends ${runtimeDeps}
    # apt install -y --no-install-recommends ${buildDeps}

    # https://github.com/asdf-vm/asdf-erlang#before-asdf-install
    # apt-get -y install \
    #   libwxgtk3.0-dev \
    #   libgl1-mesa-dev \
    #   libglu1-mesa-dev \
    #   libpng-dev

    # apt install -y --no-install-recommends \
    #   erlang-wx

    #apt purge -y --auto-remove $buildDeps

    printf "\n---> Trying to fix Observer using dir: ${erlang_wx_dir}\n"

    if [ -d "${erlang_wx_dir}" ]; then
      # https://elixirforum.com/t/observer-start-is-not-working-on-ubuntu/6018/21?u=exadra37
      #rm -rf "${erlang_lib_dir}/${erlang_wx_version}"
      mv "${erlang_lib_dir}/${erlang_wx_version}" /
      ln -s "${erlang_wx_dir}" "${erlang_lib_dir}"
      printf "\n---> Fixed Observer by linking ${erlang_lib_dir}/${erlang_wx_version} to ${erlang_wx_dir}\n"
      exit 0
    fi

    erlang_wx_dir_2="${erlang_wx_dir%.*}"

    printf "\n---> Trying to fix Observer using dir: ${erlang_wx_dir_2}\n"

    if [ -d "${erlang_wx_dir_2}" ]; then
      # https://elixirforum.com/t/observer-start-is-not-working-on-ubuntu/6018/21?u=exadra37
      #rm -rf "${erlang_lib_dir}/${erlang_wx_version}"
      mv "${erlang_lib_dir}/${erlang_wx_version}" /
      ln -s "${erlang_wx_dir_2}" "${erlang_lib_dir}/${erlang_wx_version}"
      printf "\n---> Fixed Observer by linking ${erlang_lib_dir}/${erlang_wx_version} to ${erlang_wx_dir_2}\n"
    fi
}

Main
