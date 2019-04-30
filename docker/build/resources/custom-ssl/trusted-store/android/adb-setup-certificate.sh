#!/bin/sh

set -eu

Main()
{
  ##############################################################################
  # INPUT
  ##############################################################################

    local pem_certificate_file=${1? Missing the PEM certificate file name}


  ##############################################################################
  # EXECUTION
  ##############################################################################

    # https://stackoverflow.com/a/48814971/6454622
    local certificate_name=$(openssl x509 -inform PEM -subject_hash_old -in ${pem_certificate_file} | head -1)

    cat "${pem_certificate_file}" > "${certificate_name}"
    openssl x509 -inform PEM -text -in "${pem_certificate_file}" -out nul >> "$certificate_name}"

    adb shell mount -o rw,remount,rw /system
    adb push "${certificate_name}" /system/etc/security/cacerts/
    adb shell mount -o ro,remount,ro /system
}

Main "${@}"
