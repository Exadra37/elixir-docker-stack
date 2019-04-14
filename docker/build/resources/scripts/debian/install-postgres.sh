#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local debian_version_name=${1? Missing Debian version name}
    local postgres_version=${2? Missing Postgres version !!!}
    local user_name=${3? Missing container user name !!!}


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n>>> INSTALL POSTGRES VERSION: ${postgres_version} <<< \n"

    apt install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        gnupg2

    printf "\n---> GNUPG2 IS INSTALLED \n"

    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${debian_version_name}-pgdg main" > /etc/apt/sources.list.d/postgres.list
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc -o pgp.key
    apt-key add pgp.key
    rm -f pgp.key
    #apt-key adv --fetch-keys https://www.postgresql.org/media/keys/ACCC4CF8.asc

    apt update
    apt install -y --no-install-recommends postgresql-"${postgres_version}"

    adduser "${user_name}" postgres

    ls -al /var/run/postgresql
    #chmod -s /var/run/postgresql/"${postgres_version}"-main.pg_stat_tmp
    chown -R "${user_name}":"${user_name}" /var/run/postgresql
    ls -al /var/run/postgresql

    rm -rf /var/lib/postgresql/*
    chown -R "${user_name}":"${user_name}" /var/lib/postgresql
    ls -al /var/lib/postgresql
}

Main "${@}"
