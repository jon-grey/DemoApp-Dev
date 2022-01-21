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

# generate letsencrypt certs if not existing or expired
while true; do

    echo "[$(date)][INFO] Get gcloud project id..."
    PROJECT_ID=$(jq .project_id ${KEY_PATH} -r)

    echo "[$(date)][INFO] Activate gcloud service account..."
    gcloud auth activate-service-account --key-file=${KEY_PATH} --project ${PROJECT_ID}
    echo "[$(date)][INFO] Check if service account have access to dns zones in gcloud..."
    gcloud dns managed-zones list

    acme.sh --register-account -m ${EMAIL}

    echo "[$(date)][INFO] Check if ${CA_CERT_PATH} exist for domain ${DOMAIN}."
    CA_CERT_EXIST=false
    if [ -f "${CA_CERT_PATH}" ]; then
        echo "[$(date)][INFO] Verify ${CA_CERT_PATH} via openssl for domain ${DOMAIN}."
        if openssl x509 -checkend 86400 -noout -in ${CA_CERT_PATH}; then 
            echo "[$(date)][INFO] Letsencrypt CA Certificate for domain ${DOMAIN} is good for another day!"
            CA_CERT_EXIST=true
        fi
    fi

    if ! $CA_CERT_EXIST; then
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

    (
        cd $CA_CERT_DIR

        # convert CER (PEM) to CRT (PEM) - LOL
        openssl x509 -inform PEM -in ${DOMAIN}.cer -out ${DOMAIN}.crt
        openssl x509 -inform PEM -in fullchain.cer -out fullchain.crt
        openssl x509 -inform PEM -in ca.cer -out ca.crt

        ln -sf  "${DOMAIN}.crt"  "cert.crt" 
        ln -sf  "${DOMAIN}.key"  "cert.key" 
        ln -sf  "${DOMAIN}.crt"  "${CERT_NAME}.crt" 
        ln -sf  "${DOMAIN}.key"  "${CERT_NAME}.key" 
    )


    
    echo "[$(date)][INFO] Copy certs from ${CA_CERT_DIR} to shared dir for domain ${DOMAIN}..."
    mkdir -p /root/certs/${LETSENCRYPT_SERVER}
    cp -rf $CA_CERT_DIR/* /root/certs/${LETSENCRYPT_SERVER}

    for i in `seq 10`; do
        echo "[$(date)][INFO] Waiting 60[s] iteration ${i}/600 until next check..."
        sleep 60
    done
done

# expired 03.2021
#curl https://letsencrypt.org/certs/isrgrootx1.pem.txt > isrgrootx1.pem
#curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt > lets-encrypt-x3-cross-signed.pem
#cat isrgrootx1.pem lets-encrypt-x3-cross-signed.pem > letsencrypt-ca.pem

# R3 LetsEncrypt - DUMMY way
#curl https://letsencrypt.org/certs/lets-encrypt-r3-cross-signed.pem.txt > letsencrypt-ca.pem