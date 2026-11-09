#!/bin/bash
# ==============================================================================
# 📜 FILE: srcs/requirements/mariadb/tools/init_db.sh
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This script is the automated morning routine (entrypoint) for MariaDB
#    in zsid-ele's Inception infrastructure.
#    It reads passwords safely from Docker Secrets, checks if the database is
#    brand new or already initialized, creates the WordPress database and users
#    with proper SQL permissions if needed, and finally hands over execution
#    to the foreground MariaDB daemon as PID 1.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    Imagine Master MariaDB arriving at zsid-ele's brand new, empty library.
#    He unlocks his secret briefcase (Docker Secrets) to get the master key.
#    He checks the shelves:
#    - "Are there any books here yet?"
#    - If empty: He quickly sets up a private workspace with closed shutters
#      (--skip-networking) so no strangers can peek, builds the catalog drawers
#      (CREATE DATABASE wordpress_db), writes a visitor badge for Chef WordPress
#      (CREATE USER 'zsid-ele'), and puts a titanium padlock on the master safe.
#    - Once the setup is done, he opens the front doors wide and welcomes readers!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    1. "How do you handle persistence?"
#       Answer: If `/var/lib/mysql/${MYSQL_DATABASE}` exists (from the volume),
#       the script skips user/database creation so existing data is never wiped!
#    2. "Why do you use `exec mysqld_safe` at the end?"
#       Answer: `exec` replaces the shell process with `mysqld_safe` as PID 1.
#       This allows MariaDB to receive OS signals (SIGTERM, SIGQUIT) directly
#       from Docker for clean, graceful shutdowns without corrupting data!
# ==============================================================================

# `set -e` ensures that if any command fails, the script exits immediately
# rather than continuing in a broken state.
set -e

# ------------------------------------------------------------------------------
# 💌 STEP 1: READ SECRETS SAFELY FROM MEMORY (tmpfs)
# Passwords are read from /run/secrets/ which is a RAM-only temporary filesystem.
# They are never logged to console or hardcoded in configuration files.
# ------------------------------------------------------------------------------
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# ------------------------------------------------------------------------------
# 📁 STEP 2: PREPARE RUNTIME DIRECTORIES & PERMISSIONS
# Create runtime folders for PID, socket files, data, and logs, then grant
# ownership to the 'mysql' system user so MariaDB has full write access.
# ------------------------------------------------------------------------------
mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql

# ------------------------------------------------------------------------------
# 🏗️ STEP 3: INITIALIZE SYSTEM TABLES (FIRST TIME ONLY)
# If the core system directory `/var/lib/mysql/mysql` doesn't exist, this is
# a fresh installation. `mariadb-install-db` sets up base system tables.
# ------------------------------------------------------------------------------
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Creating base MariaDB system tables for zsid-ele..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# ------------------------------------------------------------------------------
# 🔐 STEP 4: CONFIGURE APPLICATION DATABASE & PASSWORDS
# If the WordPress database folder doesn't exist yet, we spin up a temporary
# local instance of MariaDB to execute our bootstrap SQL commands.
# ------------------------------------------------------------------------------
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Bootstrapping WordPress database and users for zsid-ele (${MYSQL_USER})..."

    # Start a temporary background server without network listening (--skip-networking)
    # for maximum security during initialization.
    mysqld_safe --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    # Wait for the temporary server socket to become ready (up to 30 seconds)
    for i in $(seq 30 -1 0); do
        if mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent; then break; fi
        sleep 1
    done

    # Run SQL initialization commands through the local Unix socket
    mariadb -u root --socket=/run/mysqld/mysqld.sock <<-EOF
    -- Create the dedicated database for WordPress
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

    -- Create remote WordPress user (accessible from anywhere on inception_net '%')
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

    -- Create local WordPress user (for local socket connections)
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';

    -- Secure the root superuser account with a strong secret password
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

    -- Reload internal grant tables immediately to activate all privilege changes
    FLUSH PRIVILEGES;
EOF

    # Gracefully shut down the temporary background setup server
    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock shutdown
    wait "$pid"
    echo "MariaDB bootstrap completed successfully for zsid-ele!"
fi

# ------------------------------------------------------------------------------
# 🚀 STEP 5: LAUNCH MARIADB AS PID 1
# `exec` replaces this bash script with the permanent MariaDB server daemon.
# Now MariaDB is PID 1, listens on port 3306, and handles all container signals!
# ------------------------------------------------------------------------------
echo "Starting MariaDB in foreground for zsid-ele's Inception infrastructure..."
exec mysqld_safe --user=mysql
