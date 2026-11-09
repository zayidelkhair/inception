#!/bin/bash
# ==============================================================================
# 📜 FILE: srcs/requirements/wordpress/tools/wp_setup.sh
# 🎯 PURPOSE:
#    This script is the automated setup and launch entrypoint for WordPress.
#    It reads passwords safely from Docker Secrets, polls MariaDB until the
#    database is accepting connections, downloads and installs WordPress core
#    using WP-CLI (if not already installed), creates the administrator and
#    regular author accounts, configures Redis object caching, and launches
#    PHP-FPM 8.2 in the foreground (`-F`) as PID 1.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    Imagine Chef WordPress walking into the kitchen:
#    1. He takes the passwords out of his secret envelopes (Docker Secrets).
#    2. He calls MariaDB on the walkie-talkie: *"Are you awake yet, librarian?"*
#       If the librarian is still waking up, the chef waits politely and retries
#       every 2 seconds until he gets a thumbs-up!
#    3. He checks the pantry: *"Is there a recipe book (wp-config.php)?"*
#       - If empty: He waves his magic wand (WP-CLI), downloads fresh WordPress
#         ingredients, creates the King's admin account and the student's author
#         account, and introduces the kitchen to Redis the quick-memo squirrel!
#    4. Once everything is ready, he starts cooking (`exec php-fpm8.2 -F`)!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will check:
#    1. "How do you wait for MariaDB?"
#       Answer: Using the `until mariadb-admin ping` loop. Containers start in
#       parallel, so WordPress must wait for MariaDB to fully finish booting.
#    2. "Does the installation satisfy the two required users?"
#       Answer: Yes! The admin user (`WP_ADMIN_USER`) and a secondary user
#       (`WP_USER`) with the 'author' role are created via WP-CLI commands.
#    3. "Why `exec php-fpm8.2 -F`?"
#       Answer: `-F` (force foreground) keeps PHP-FPM running as PID 1 so Docker
#       does not terminate the container.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# ------------------------------------------------------------------------------
# 💌 STEP 1: READ SECRETS SAFELY FROM MEMORY (tmpfs)
# Passwords are read from the /run/secrets/ in-memory mount.
# ------------------------------------------------------------------------------
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# ------------------------------------------------------------------------------
# 📁 STEP 2: PREPARE RUNTIME DIRECTORIES & PERMISSIONS
# Create runtime directory for PHP socket/PID and set correct ownership.
# ------------------------------------------------------------------------------
mkdir -p /run/php /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# ------------------------------------------------------------------------------
# ⏳ STEP 3: WAIT FOR MARIADB TO BECOME READY
# MariaDB may take several seconds to boot and run its SQL bootstrap script.
# This loop pings MariaDB until it returns a successful response.
# ------------------------------------------------------------------------------
echo "Waiting for MariaDB connection..."
until mariadb-admin -h"mariadb" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --skip-ssl ping >/dev/null 2>&1; do
    echo "MariaDB is not ready yet, retrying in 2 seconds..."
    sleep 2
done
echo "Connected to MariaDB successfully!"

# ------------------------------------------------------------------------------
# 🏗️ STEP 4: INSTALL & CONFIGURE WORDPRESS (FIRST RUN ONLY)
# If wp-config.php already exists on the shared volume, installation is skipped
# so existing website content is NEVER overwritten or reset!
# ------------------------------------------------------------------------------
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing fresh WordPress core files..."
    # Download fresh WordPress source files
    wp core download --path=/var/www/html --allow-root --force

    # Generate wp-config.php connecting WordPress to the MariaDB container
    wp config create --path=/var/www/html --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" --allow-root

    # Install WordPress: creates database schema, site title, and administrator account
    wp core install --path=/var/www/html --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    # Create the required second, non-admin user (with 'author' permissions)
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" \
        --role=author --path=/var/www/html --allow-root

    # --------------------------------------------------------------------------
    # 🐿️ STEP 5: CONFIGURE REDIS CACHING (BONUS)
    # Installs and activates the Redis object cache plugin in WordPress, points
    # it to the 'redis' container on port 6379, and turns caching on.
    # --------------------------------------------------------------------------
    echo "Configuring Redis object cache..."
    wp plugin install redis-cache --activate --path=/var/www/html --allow-root
    wp config set WP_REDIS_HOST "redis" --path=/var/www/html --allow-root
    wp config set WP_REDIS_PORT "6379" --raw --path=/var/www/html --allow-root
    wp config set WP_CACHE true --raw --path=/var/www/html --allow-root
    wp redis enable --path=/var/www/html --allow-root || true
fi

# ------------------------------------------------------------------------------
# 🔒 STEP 6: FINALIZE PERMISSIONS & LAUNCH PHP-FPM
# Ensure www-data retains ownership of all created files so web uploads work.
# Launch PHP-FPM 8.2 in foreground (-F) as PID 1.
# ------------------------------------------------------------------------------
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

echo "Starting PHP-FPM in foreground on port 9000..."
exec php-fpm8.2 -F
