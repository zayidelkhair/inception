# ==============================================================================
# 📜 FILE: srcs/requirements/mariadb/Dockerfile
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for the MariaDB relational
#    database server for zsid-ele's Inception infrastructure. It installs the
#    database engine on top of Debian Bookworm, copies the custom server
#    configuration, injects the automated bootstrap script, and specifies that
#    Port 3306 will be used for database queries.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    Imagine you want to build a cozy, ultra-secure stone library for zsid-ele!
#    You don't buy a pre-furnished house from a catalog (pre-built images are
#    forbidden by the 42 rules!). Instead, you start with a clean plot of land
#    (Debian Bookworm), hire builders to install empty bookshelves and filing
#    cabinets (mariadb-server), hand the head librarian his rulebook
#    (50-server.cnf), and give him a morning checklist script (init_db.sh)
#    to set up the keys and secret vaults before the castle gates open!
#
# 🎓 EVALUATION CHECKPOINT:
#    - Base image MUST be penultimate stable Debian (Bookworm) or Alpine.
#    - MUST NOT use `latest` tag or pre-made `mariadb:latest` from Docker Hub.
#    - Layers must be minimized (`rm -rf /var/lib/apt/lists/*` to save space).
#    - ENTRYPOINT executes `init_db.sh` to initialize the database dynamically.
# ==============================================================================

# 🧱 BASE LAYER: Debian Bookworm (Debian 12)
FROM debian:bookworm

# 🏷️ REBRANDING METADATA:
LABEL maintainer="zsid-ele <zsid-ele@student.42abudhabi.ae>"
LABEL project="Inception - 42 Abu Dhabi"
LABEL description="Custom MariaDB container built from scratch by zsid-ele"

# ------------------------------------------------------------------------------
# 📦 PACKAGE INSTALLATION:
# - `apt-get update`: Refreshes package catalog lists.
# - `mariadb-server`: The actual database engine daemon that stores data.
# - `mariadb-client`: Command-line tools (e.g. `mariadb-admin`, `mysql`) used
#    by startup scripts to communicate with the server.
# - `--no-install-recommends`: Prevents installing unnecessary bloated packages.
# - `rm -rf /var/lib/apt/lists/*`: Cleans up temporary download lists to keep
#    the image lightweight (reduces image size by ~30-50MB!).
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# ⚙️ CONFIGURATION & SCRIPTS:
# - `50-server.cnf`: Custom MySQL settings (networking, charset, ports).
# - `init_db.sh`: Startup script that reads secrets and creates tables.
# - `chmod +x`: Gives execution permissions so Linux can run the script.
# ------------------------------------------------------------------------------
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

# ------------------------------------------------------------------------------
# 🚪 INTERNAL PORT DECLARATION:
# 3306 is the standard default port for MySQL and MariaDB servers.
# Note: EXPOSE is informative documentation for Docker; it does NOT open this
# port to the public internet!
# ------------------------------------------------------------------------------
EXPOSE 3306

# ------------------------------------------------------------------------------
# 🚀 ENTRYPOINT:
# Specifies the exact program that runs when the container starts.
# When MariaDB wakes up, it executes our initialization script `init_db.sh`.
# ------------------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
