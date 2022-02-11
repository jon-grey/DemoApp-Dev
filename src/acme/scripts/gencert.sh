#!/bin/bash -xeuo pipefail

set -euo pipefail

alias acme.sh=${HOME}/.acme.sh/acme.sh


! command -v jq --version >/dev/null 2>&1 && {
    echo "[$(date)][INFO] ABORT. Not found jq..."
    exit 1
}

! command -v gcloud --version >/dev/null 2>&1 && {
    echo "[$(date)][INFO] ABORT. Not found gcloud..."
    exit 1
}

# [acme.sh/acme.sh at master · acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh/blob/master/acme.sh)
! command -v acme.sh --version >/dev/null 2>&1 && {
    echo "[$(date)][INFO] ABORT. Not found acme.sh..."
    exit 1
}


echo "[$(date)][INFO] gcloud version $(gcloud --version)..."
echo "[$(date)][INFO] acme.sh version $(acme.sh --version)..."
echo "[$(date)][INFO] jq version $(jq --version)..."

sq="'"

# FIXUP for ERR {It seems that "\*.example.com" is an IDN( Internationalized Domain Names), please install 'idn' command first.
DOMAIN=$(echo ${DOMAIN} | tr -d '"')
FULLCHAIN_BACKUP_PATH=/root/certs/${LETSENCRYPT_SERVER}/fullchain.cer


# generate letsencrypt certs if not existing or expired
echo "[$(date)][INFO] Get gcloud project id..."
PROJECT_ID=$(jq .project_id ${KEY_PATH} -r)

echo "[$(date)][INFO] Activate gcloud service account..."
gcloud auth activate-service-account --key-file=${KEY_PATH} --project ${PROJECT_ID}
echo "[$(date)][INFO] Check if service account have access to dns zones in gcloud..."
gcloud dns managed-zones list

acme.sh --register-account -m ${EMAIL}

echo "[$(date)][INFO] Check if ${FULLCHAIN_PATH} or (BACKUP) ${FULLCHAIN_BACKUP_PATH} exist for domain ${DOMAIN}."
FULLCHAIN_EXIST=false
if [ -f "${FULLCHAIN_PATH}" ]; then
    echo "[$(date)][INFO] Verify ${FULLCHAIN_PATH} via openssl for domain ${DOMAIN}."
    if openssl x509 -checkend 86400 -noout -in ${FULLCHAIN_PATH}; then 
        echo "[$(date)][INFO] Letsencrypt CA Certificate for domain ${DOMAIN} is good for another day!"
        FULLCHAIN_EXIST=true
    fi
elif [ -f "${FULLCHAIN_BACKUP_PATH}" ]; then
    echo "[$(date)][INFO] Verify ${FULLCHAIN_BACKUP_PATH} via openssl for domain ${DOMAIN}."
    if openssl x509 -checkend 86400 -noout -in ${FULLCHAIN_BACKUP_PATH}; then
        echo "[$(date)][INFO] Letsencrypt CA Certificate BACKUP for domain ${DOMAIN} is good for another day!"
        FULLCHAIN_EXIST=true
    fi
fi

if ! $FULLCHAIN_EXIST; then
    echo "[$(date)][INFO] Letsencrypt CA Certificate has expired or will do so within 24 hours (or is invalid/not found)!"
    echo "[$(date)][INFO] Use acme.sh grab letsencrypt CA that will be used with gcloud dns subdomain."

    if [ "${LETSENCRYPT_SERVER}" == "prod" ]; then
        echo "[$(date)][INFO] Order PROD letsencrypt cert."
        ${HOME}/.acme.sh/acme.sh --issue --log --dns dns_gcloud --domain ${DOMAIN} --server letsencrypt
    else
        echo "[$(date)][INFO] Order STAG letsencrypt cert."
        ${HOME}/.acme.sh/acme.sh --issue --log --dns dns_gcloud --domain ${DOMAIN} --server letsencrypt_test --staging
    fi
fi

if [ -f "${FULLCHAIN_PATH}" ]; then
    echo "[$(date)][INFO] Copy .cer CERTS to .crt IN $CA_CERT_DIR..."
    (
        cd $CA_CERT_DIR

        # convert CER (PEM) to CRT (PEM) - LOL
        cp ${DOMAIN}.cer  ${DOMAIN}.crt
        cp fullchain.cer  fullchain.crt
        cp ca.cer         ca.crt

        cp  "${DOMAIN}.crt"  "cert.crt" 
        cp  "${DOMAIN}.key"  "cert.key" 
        cp  "${DOMAIN}.crt"  "${CERT_NAME}.crt" 
        cp  "${DOMAIN}.key"  "${CERT_NAME}.key" 
    )

    echo "[$(date)][INFO] Copy certs from ${CA_CERT_DIR} to shared dir for domain ${DOMAIN}..."
    mkdir -p /root/certs/${LETSENCRYPT_SERVER}
    cp -rf $CA_CERT_DIR/* /root/certs/${LETSENCRYPT_SERVER}
fi

if [ -f "${FULLCHAIN_BACKUP_PATH}" ]; then
    echo "[$(date)][INFO] Copy .cer CERTS to .crt IN /root/certs/${LETSENCRYPT_SERVER}..."
    (
        cd /root/certs/${LETSENCRYPT_SERVER}

        # convert CER (PEM) to CRT (PEM) - LOL
        cp ${DOMAIN}.cer  ${DOMAIN}.crt
        cp fullchain.cer  fullchain.crt
        cp ca.cer         ca.crt

        cp  "${DOMAIN}.crt"  "cert.crt" 
        cp  "${DOMAIN}.key"  "cert.key" 
        cp  "${DOMAIN}.crt"  "${CERT_NAME}.crt" 
        cp  "${DOMAIN}.key"  "${CERT_NAME}.key" 
    )
fi

echo "[$(date)][INFO] Waiting 360[s]..."
sleep 360

# expired 03.2021
#curl https://letsencrypt.org/certs/isrgrootx1.pem.txt > isrgrootx1.pem
#curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt > lets-encrypt-x3-cross-signed.pem
#cat isrgrootx1.pem lets-encrypt-x3-cross-signed.pem > letsencrypt-ca.pem

# R3 LetsEncrypt - DUMMY way
#curl https://letsencrypt.org/certs/lets-encrypt-r3-cross-signed.pem.txt > letsencrypt-ca.pem