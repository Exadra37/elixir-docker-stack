#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local crt_certificate_file_path="${1? Missing path for CRT file of the custom authority certificate !!!}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    if [ -f "${crt_certificate_file_path}" ]; then

      printf "\n>>> ADDING A CUSTOM AUTHORITY CERTIFICATE TO THE TRUSTED STORE <<<\n"

      # add certificate to the trust store
      cp -v "${crt_certificate_file_path}" /usr/local/share/ca-certificates
      update-ca-certificates

      # verifies the certificate
      openssl x509 -in "${crt_certificate_file_path}" -text -noout > "${crt_certificate_file_path}.txt"

      exit 0
    fi

    printf "\n >>> No Custom Certificate to be added from path: ${crt_certificate_file_path} <<<\n"
}

Main "${@}"
