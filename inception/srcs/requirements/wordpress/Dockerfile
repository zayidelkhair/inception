# ==============================================================================
# 📜 FILE: srcs/requirements/wordpress/Dockerfile
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for WordPress and PHP-FPM 8.2
#    for zsid-ele's Inception infrastructure. It installs PHP and its required
#    extensions (including MariaDB client and Redis caching support), downloads
#    the WP-CLI management tool, installs our PHP pool configuration (`www.conf`),
#    and registers the automated setup script.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    This builds Chef WordPress's Kitchen for zsid-ele!
#    We start with a sturdy room (Debian Bookworm), install modern cooking
#    appliances (PHP-FPM 8.2), give the chef a telephone to call the library
#    (php-mysql), a quick-memo notepad (php-redis), and a magic wand called
#    WP-CLI that lets him download WordPress and install users automatically!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    - "Why is WP-CLI installed?"
#      Answer: WP-CLI allows command-line installation and configuration of
#      WordPress without requiring manual clicking through a web installer browser UI.
#    - "Does WordPress contain NGINX?"
#      Answer: NO! Each service runs in its own separate container. WordPress
#      runs PHP-FPM on port 9000; NGINX runs independently in another container.
# ==============================================================================

# 🧱 BASE LAYER: Penultimate stable Debian release
FROM debian:bookworm

# 🏷️ REBRANDING METADATA:
LABEL maintainer="zsid-ele <zsid-ele@student.42abudhabi.ae>"
LABEL project="Inception - 42 Abu Dhabi"
LABEL description="Custom WordPress & PHP-FPM container built from scratch by zsid-ele"

# ------------------------------------------------------------------------------
# 📦 PACKAGE INSTALLATION:
# - `php8.2-fpm`: FastCGI Process Manager for PHP.
# - `php8.2-mysql`: Driver enabling PHP to connect to MariaDB.
# - `php-redis`: Extension enabling WordPress to cache objects in Redis.
# - `curl`, `ca-certificates`: Needed to download WP-CLI securely over HTTPS.
# - `mariadb-client`: Provides `mariadb-admin ping` to check if MariaDB is ready.
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends php8.2-fpm php8.2-mysql php8.2-curl \
    php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php-redis mariadb-client curl \
    ca-certificates && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# 🪄 INSTALL WP-CLI (WordPress Command Line Interface)
# Downloads the standalone executable phar archive, marks it executable,
# and moves it to the global `/usr/local/bin/wp` directory.
# ------------------------------------------------------------------------------
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# ------------------------------------------------------------------------------
# ⚙️ CONFIGURATION & SCRIPTS:
# - Copy custom `www.conf` pool configuration for PHP-FPM.
# - Copy the automated setup script `wp_setup.sh`.
# ------------------------------------------------------------------------------
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

# ------------------------------------------------------------------------------
# 📂 WORKING DIRECTORY & PORT:
# Sets default working directory to the shared WordPress website directory.
# Exposes internal port 9000 for FastCGI communication with NGINX.
# ------------------------------------------------------------------------------
WORKDIR /var/www/html
EXPOSE 9000

# ------------------------------------------------------------------------------
# 🚀 ENTRYPOINT:
# Launches `wp_setup.sh` on container boot.
# ------------------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]
