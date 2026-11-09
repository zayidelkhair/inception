# ==============================================================================
# 📜 FILE: srcs/requirements/bonus/adminer/Dockerfile
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for Adminer in zsid-ele's
#    Inception infrastructure. It installs PHP and its MySQL extension,
#    downloads the official Adminer script, and runs PHP's built-in web
#    server on port 8080.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    This builds the Librarian's Glass Control Room for zsid-ele!
#    Instead of carrying a giant encyclopedia, the librarian downloads one
#    magic sheet of paper (`adminer-4.8.1.php`). He sets up a little display
#    stand (`php -S 0.0.0.0:8080`) so zsid-ele can peek into all the database
#    drawers right from a web browser without writing confusing computer code!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    - "How is Adminer accessed?"
#      Answer: Through NGINX at `https://zsid-ele.42.fr/adminer`. NGINX receives
#      the HTTPS request and reverse-proxies it internally to `adminer:8080`.
#    - "Why use Adminer instead of phpMyAdmin?"
#      Answer: Adminer is a clean, single PHP file with a tiny resource footprint,
#      fewer security vulnerabilities, and lightning-fast boot times.
# ==============================================================================

# 🧱 BASE LAYER: Penultimate stable Debian release
FROM debian:bookworm

# 🏷️ REBRANDING METADATA:
LABEL maintainer="zsid-ele <zsid-ele@student.42abudhabi.ae>"
LABEL project="Inception - 42 Abu Dhabi"

# ------------------------------------------------------------------------------
# 📦 PACKAGE INSTALLATION:
# - `php`: CLI PHP interpreter to run the built-in server.
# - `php-mysql`: MySQL extension to allow Adminer to talk to MariaDB.
# - `wget`, `ca-certificates`: Tools to securely download the Adminer release.
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends php php-mysql wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# 📥 DOWNLOAD ADMINER:
# Creates the web root directory and downloads the official standalone script.
# Renaming it to `index.php` allows PHP's built-in server to serve it automatically.
# ------------------------------------------------------------------------------
RUN mkdir -p /var/www/adminer
WORKDIR /var/www/adminer
RUN wget -O index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

# ------------------------------------------------------------------------------
# 🚪 PORT EXPOSURE:
# Internal listening port 8080 (proxied via NGINX).
# ------------------------------------------------------------------------------
EXPOSE 8080

# ------------------------------------------------------------------------------
# 🚀 ENTRYPOINT:
# Uses PHP's built-in web server (`php -S`) listening on all interfaces (`0.0.0.0:8080`)
# with the document root set to `/var/www/adminer`.
# ------------------------------------------------------------------------------
ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
