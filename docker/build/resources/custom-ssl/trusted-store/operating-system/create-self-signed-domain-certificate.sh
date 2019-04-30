#!/bin/sh

set -eu


################################################################################
#
# Inspired by:
#   *  https://fabianlee.org/2018/02/17/ubuntu-creating-a-trusted-ca-and-san-certificate-using-openssl-on-ubuntu/
#
# Creates and adds a self signed certificate for the given domain name to use in
# a localhost development.
#
# It will sign the certificate with the self signed root certificate from:
#   * ./custom-ssl/trusted-store/operating-system/create-and-add-self-signed-root-certificate.sh
#

Build_Domain_Config()
{
  local domain_name=${1? Missing domain name !!!}

  echo "
[ v3_req ]

# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

#extendedKeyUsage=serverAuth
subjectAltName = @alt_names


[ alt_names ]

DNS.1 = ${domain_name}
DNS.2 = *.${domain_name}
"
}

Main()
{
  ##############################################################################
  # IMPUT
  ##############################################################################

    local domain_name="${1:-localhost}"
    local root_certicate_name="${2:-Self_Signed_Root_CA}"
    local openssl_config_file="${3:-./config/openssl.cnf}"


  ##############################################################################
  # CONSTANT VARS
  ##############################################################################

    local ROOT_CA_KEY="${root_certicate_name}.key"
    local ROOT_CA_PEM="${root_certicate_name}.pem"
    local DOMAIN_CA_KEY="${domain_name}.key"
    local DOMAIN_CA_CSR="${domain_name}.csr"
    local DOMAIN_CA_CRT="${domain_name}.crt"
    local CONFIG_FILE="${domain_name}.cnf"


  ##############################################################################
  # EXECUTION
  ##############################################################################

    printf "\n>>> CREATING DOMAIN CONFIGURATION INTO ${CONFIG_FILE} <<<\n"
    local domain_config=$(Build_Domain_Config "${domain_name}")
    local openssl_config=$(cat "${openssl_config_file}")

    echo "${openssl_config}" > "${CONFIG_FILE}"
    echo "${domain_config}" >> "${CONFIG_FILE}"

    printf "\n>>> GENERATING KEY FOR DOMAIN CERTIFICATE: ${DOMAIN_CA_KEY} <<<\n"

    # generate the private/public RSA key pair for the domain
    openssl genrsa -out "${DOMAIN_CA_KEY}" 4096

    printf "\n>>> GENERATING CSR FOR DOMAIN CERTIFICATE: ${DOMAIN_CA_CSR} <<<\n"

    # create the server certificate signing request:
    openssl req \
        -subj "/CN=${domain_name}" \
        -extensions v3_req \
        -sha256 \
        -new \
        -key "${DOMAIN_CA_KEY}" \
        -out "${DOMAIN_CA_CSR}"

    printf "\n>>> GENERATING CRT FOR DOMAIN CERTIFICATE: ${DOMAIN_CA_CRT} <<<\n"

    # generate the server certificate using the: server signing request, the CA signing key, and CA cert.
    openssl x509 \
                -req \
                -extensions v3_req \
                -days 3650 \
                -sha256 \
                -in "${DOMAIN_CA_CSR}" \
                -CA "${ROOT_CA_PEM}" \
                -CAkey "${ROOT_CA_KEY}" \
                -CAcreateserial \
                -out "${DOMAIN_CA_CRT}" \
                -extfile "${CONFIG_FILE}"

    # verifies the certificate
    openssl x509 -in "${DOMAIN_CA_CRT}" -text -noout > "${domain_name}".txt

    printf "\n >>> CERTIFICATE CREATED FOR DOMAIN: ${domain_name} <<<\n"
}

Main "${@}"
