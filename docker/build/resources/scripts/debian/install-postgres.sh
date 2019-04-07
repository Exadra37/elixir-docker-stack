#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local debian_version_name=${1? Missing Debian version name}
    local postgres_version=${2? Missing Postgres version !!!}
    local container_user_name=${3? Missing container user name !!!}


  ##############################################################################
  # EXECUTION
  ##############################################################################

    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${debian_version_name}-pgdg main" > /etc/apt/sources.list.d/postgres.list
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

    apt update
    apt install -y \
      postgresql-"${postgres_version}"

      # postgresql-11-client \
      # postgresql-11-contrib \
      # postgresql-11-libs \
      # postgresql-11-dev

    adduser "${container_user_name}" postgres
    #adduser postgres "${CONTAINER_USER}"

    ls -al /var/run/postgresql
    #chmod -s /var/run/postgresql/"${postgres_version}"-main.pg_stat_tmp
    chown -R "${container_user_name}":"${container_user_name}" /var/run/postgresql
    ls -al /var/run/postgresql

    rm -rvf /var/lib/postgresql/*
    chown -R "${container_user_name}":"${container_user_name}" /var/lib/postgresql
    ls -al /var/lib/postgresql
}

Main "${@}"
