#!/bin/sh

set -eu

################################################################################
# Inspired on https://thomas-leister.de/en/how-to-import-ca-root-certificate/
#
# Script installs root.cert.pem to certificate trust store of applications using
# NSS (e.g. Firefox, Thunderbird, Chromium)
#
# Mozilla uses cert8, Chromium and Chrome use cert9
#
# Requirement: apt install libnss3-tools
#

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local pem_certificate_file_path="${1? Missing file path for the PEM certificate}"
    local certificate_name="${2?Missing Certificate Name}"
    local browser_config_dir="${3:-/home/node}"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n>>> ADDING CERTIFICATE TO BROWSERS TRUSTED STORE <<<\n"
    printf "\n--> CERTIFICATE FILE: ${pem_certificate_file_path}\n"

    if [ -f "${pem_certificate_file_path}" ]; then

      apt install -y libnss3-tools

      printf "\n--> CERTIFICATE NAME: ${certificate_name}\n"
      printf "\n--> BROWSER CONFIG DIR: ${browser_config_dir} \n"

      # For cert8 (legacy - DBM) - Mozilla
      for certificate_database in $(find "${browser_config_dir}" -name "cert8.db"); do
        local certificate_dir=$(dirname ${certificate_database});
        certutil -A -n "${certificate_name}" -t "TCu,Cu,Tu" -i "${pem_certificate_file_path}" -d dbm:"${certificate_dir}"
      done

      # For cert9 (SQL) - Chromium and Chrome
      for certificate_database in $(find "${browser_config_dir}" -name "cert9.db"); do
        local certificate_dir=$(dirname ${certificate_database})
        certutil -A -n "${certificate_name}" -t "TCu,Cu,Tu" -i "${pem_certificate_file_path}" -d sql:"${certificate_dir}"
      done

      exit 0
    fi

    printf "\n>>> CERTIFICATE FILE NOT FOUND FOR: ${pem_certificate_file_path}\n"
}

Main "${@]"
