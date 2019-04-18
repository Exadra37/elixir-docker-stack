#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # EXECUTION
  ##############################################################################

    apt install -y -q --no-install-recommends inotify-tools

    printf "fs.inotify.max_user_watches=524288\n" > /etc/sysctl.d/01-inotify.conf
}

Main
