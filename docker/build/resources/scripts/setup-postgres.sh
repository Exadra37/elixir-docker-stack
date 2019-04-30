#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local postgres_version=${1? Missing Postgres version !!!}
    local postgres_user=${2? Missing Postgres user !!!}
    local postgres_password=${3? Missing postgres_password !!!}


  ##############################################################################
  # EXECUTION
  ##############################################################################

    # initdb
    bash -c "eval 'initdb --allow-group-access --username=postgres --pwfile=<(echo postgres)'"

    # https://docs.docker.com/engine/examples/postgresql_service/
    pg_ctl start
    #psql -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres'"
    createdb --username postgres --owner postgres testapp_dev
    createdb --username postgres --owner postgres testapp_test
    createdb --username postgres --owner postgres testapp_prod
}

Main "${@}"
