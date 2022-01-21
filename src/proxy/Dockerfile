
FROM nginxproxy/nginx-proxy:alpine AS proxy

ARG ENV="development"
ARG HOST_TYPE="localhost"
ARG DOMAIN="*.gke-test.localtest.pl"
ARG CERT_NAME="gke-test.localtest.pl"
ENV CA_CERT "ca.cer"
ENV CA_DIR "/root/.acme.sh"
RUN ls -la /home

# The contents of /path/to/certs should contain the certificates and private keys for any virtual hosts in use.
# The certificate and keys should be named after the virtual host with a .crt and .key extension. For example,
# a container with VIRTUAL_HOST=foo.bar.com should have a foo.bar.com.crt and foo.bar.com.key file in the certs directory.
WORKDIR /etc/nginx/certs

# COPY config/${HOST_TYPE}/nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
