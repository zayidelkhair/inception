#!/bin/bash
# ==============================================================================
# 📜 FILE: srcs/requirements/nginx/tools/nginx_setup.sh
# 🎯 PURPOSE:
#    This script prepares NGINX before it begins serving web traffic.
#    It generates a fresh, self-signed TLS/SSL certificate specifically for the
#    configured DOMAIN_NAME (e.g. `zsid-ele.42.fr`), injects the domain name
#    into NGINX configuration, and launches NGINX in the foreground (`daemon off;`)
#    as PID 1.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    Imagine Sir NGINX putting on his golden badge every morning!
#    Before opening the castle drawbridge:
#    1. He uses his golden stamp tool (`openssl`) to craft a fresh ID badge
#       stamped with the Kingdom's official name.
#    2. He writes the Kingdom's name neatly on the sign above the gate (`sed`).
#    3. He stands alert at the front door (`nginx -g 'daemon off;'`) and never
#       leaves his post, greeting every visitor with a smile!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask: "Why do you pass `daemon off;` to NGINX?"
#    Answer: By default, NGINX runs in the background (as a daemon) and exits
#    the main shell. In Docker, if PID 1 exits, Docker thinks the container has
#    finished its job and IMMEDIATELY kills the container! Running `daemon off;`
#    keeps NGINX in the foreground as PID 1 so the container stays alive.
# ==============================================================================

# Exit immediately if any command returns a non-zero exit status
set -e

# ------------------------------------------------------------------------------
# 🔐 STEP 1: GENERATE DYNAMIC TLS/SSL CERTIFICATE
# - `req -x509`: Creates a self-signed certificate rather than a signing request.
# - `-nodes`: "No DES" - does not encrypt the private key with a passphrase,
#   allowing NGINX to start automatically without human password typing!
# - `-days 365`: Valid for 1 full year.
# - `-newkey rsa:2048`: Generates a standard 2048-bit RSA cryptographic key pair.
# - `-subj`: Subject information containing the domain name from our `.env` file.
# ------------------------------------------------------------------------------
echo "Generating self-signed TLS certificate for ${DOMAIN_NAME}..."
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME}"

# ------------------------------------------------------------------------------
# 📝 STEP 2: CONFIGURE SERVER NAME IN NGINX CONFIG
# Uses stream editor `sed` to replace the placeholder string with the actual
# domain name set in `.env` (e.g. `zsid-ele.42.fr`).
# ------------------------------------------------------------------------------
echo "Configuring NGINX server name to ${DOMAIN_NAME}..."
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

# ------------------------------------------------------------------------------
# 🚀 STEP 3: EXECUTE NGINX IN FOREGROUND (PID 1)
# `exec`: Replaces the current shell process with the NGINX binary.
# `daemon off;`: Prevents NGINX from backgrounding, keeping the container alive.
# ------------------------------------------------------------------------------
echo "Starting NGINX in foreground on port 443..."
exec nginx -g "daemon off;"
