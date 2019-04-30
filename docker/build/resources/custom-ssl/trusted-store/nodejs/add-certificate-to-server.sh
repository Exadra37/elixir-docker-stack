#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local pem_certificate_file=${1? Missing certificate file name !!!}
    local home_dir=${2? Missing home dir !!!}


  ##############################################################################
  # VARS
  ##############################################################################

    local certificate_extension="${pem_certificate_file##*.}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    if [ "${certificate_extension}" != "pem" ]; then

      printf "\nFATAL ERROR: Certificate must use .pem extension \n\n"
      exit 1
    fi

    if [ -f "${pem_certificate_file}" ]; then

      printf "\n>>> ADDING A CERTIFICATE TO NODEJS SERVER <<<\n"

      # Add certificate to node, so that we can use npm install
      printf "cafile=${pem_certificate_file}" >> /root/.npmrc
      printf "cafile=${pem_certificate_file}" >> "${home_dir}"/.npmrc;

      printf "\n >>> CERTICATE ADDED SUCCESEFULY<<<\n"

      exit0
    fi

    printf "\n >>> NO CERTIFICATE TO ADD <<<\n"

}

Main "${@}"
