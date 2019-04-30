#!/bin/sh

set -eu

################################################################################
#
# Inspired by:
#   * https://fabianlee.org/2018/02/17/ubuntu-creating-a-trusted-ca-and-san-certificate-using-openssl-on-ubuntu/
#
# Creates and add a self signed root certificate to sign doamin to be used in a
# localhost development.
#
# To generate a domain for localhost development use:
#   * ./custom-ssl/create-domain-certificate.sh
#

Main()
{
  ##############################################################################
  # IMPUT
  ##############################################################################

    local root_certicate_name="${1:-Self_Signed_Root_CA}"
    local openssl_config_file="${2:-./config/openssl.cnf}"


  ##############################################################################
  # VARS
  ##############################################################################

    local root_certificate_key_file="${root_certicate_name}.key"
    local root_certificate_pem_file="${root_certicate_name}.pem"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    if [ -f "${root_certificate_pem_file}" ]; then

      printf "\n >>> SELF SIGNED ROOT PEM CERTICATE FILE ALREADY EXISTS <<<\n"

      # we want only to return a warning, not an error.
      exit 0
    fi

    printf "\n>>> CREATING A SELF SIGNED ROOT CERTIFICATE <<<\n"

    openssl req \
      -new \
      -newkey rsa:4096 \
      -days 3650 \
      -nodes \
      -x509 \
      -extensions v3_ca \
      -subj "/C=US/ST=CA/L=SF/O=${root_certicate_name}/CN=${root_certicate_name}" \
      -keyout "${root_certificate_key_file}" \
      -out "${root_certificate_pem_file}" \
      -config "${openssl_config_file}"

    printf "\n>>> ADDING SELF SIGNED ROOT CERTIFICATE TO THE OPERATING SYSTEM TRUSTED STORE <<<\n"

    # add certificate to the trust store
    cp "${root_certificate_pem_file}" /usr/local/share/ca-certificates/"${root_certicate_name}".crt
    update-ca-certificates

    # verifies the certificate
    openssl x509 -in "${root_certificate_pem_file}" -text -noout > "${root_certicate_name}.txt"

    printf "\n >>> SELF SIGNED ROOT CERTICATE CREATED SUCCESEFULY<<<\n"
}

Main "${@}"
