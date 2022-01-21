FROM google/cloud-sdk:369.0.0-alpine AS gcloud-acme-stage


ARG KEY_FILE="gcloud.json"
ENV KEYS_DIR "/data/secrets"
ENV KEY_PATH "${KEYS_DIR}/${KEY_FILE}"
ENV SCRIPTS_DIR "/root/scripts"
ENV CA_DIR "/root/.acme.sh"
ENV PATH "${CA_DIR}:${PATH}"

RUN apk add curl openssl socat jq && \
    rm -rf /var/cache/apk/*

ARG EMAIL="robert.grzelka@ralf-it.com"
RUN set -x && \
    curl https://get.acme.sh | sh -s email=${EMAIL}

ARG LETSENCRYPT_SERVER="stag"
ARG DOMAIN="*.gke-test.localtest.pl"
ENV CA_CERT_DIR "${CA_DIR}/${DOMAIN}"
ENV CA_CERT_PATH "${CA_CERT_DIR}/ca.cer"

# copy service account secret
COPY secrets/${KEY_FILE} ${KEY_PATH}

WORKDIR ${SCRIPTS_DIR}
COPY scripts/gencert.sh gencert.sh


ENTRYPOINT [ "bash" ]
CMD [ "gencert.sh" ]


