#!/bin/bash
# ==============================================================================
# 📜 FILE: srcs/requirements/bonus/ftp/tools/ftp_setup.sh
# 🎯 PURPOSE:
#    This script bootstraps the FTP server container before starting `vsftpd`.
#    It reads the FTP password safely from Docker Secrets, creates the Linux
#    user account (`FTP_USER`), sets its home folder to `/var/www/html`, adds
#    the user to the `www-data` group, configures the passive mode IP address,
#    and runs `vsftpd` in the foreground as PID 1.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    Imagine the Delivery Postmaster setting up his station!
#    1. He takes the secret password out of the wax-sealed envelope (Docker Secrets).
#    2. He prints a delivery badge for the courier (`useradd ftpuser`).
#    3. He says: *"Your delivery destination is the WordPress toy room (/var/www/html).
#       You share the room with the baker (www-data) so you can both organize toys!"*
#    4. He writes down the station's radio frequency (`sed` passive address).
#    5. He stands at the desk and starts accepting packages (`exec vsftpd`)!
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    1. "Where does the FTP user upload files?"
#       Answer: Directly into `/var/www/html`, which is mounted from the shared
#       persistent `wordpress_vol` volume.
#    2. "How do you avoid permission conflicts with WordPress?"
#       Answer: We add `FTP_USER` to the `www-data` group (`usermod -aG www-data`)
#       and set `local_umask=002` so both can read and write the same files.
# ==============================================================================

# Exit immediately if any command returns a non-zero exit status
set -e

# ------------------------------------------------------------------------------
# 💌 STEP 1: READ PASSWORD SAFELY FROM DOCKER SECRETS
# Reads the password from the memory-mounted /run/secrets/ file.
# ------------------------------------------------------------------------------
FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# ------------------------------------------------------------------------------
# 👤 STEP 2: CREATE FTP SYSTEM USER (FIRST RUN ONLY)
# If the user does not exist in the container yet, create it:
# - `-m -d /var/www/html`: Sets home directory to the WordPress root folder.
# - `-s /bin/bash`: Sets default shell.
# - `chpasswd`: Applies the secret password to the account.
# - `usermod -aG www-data`: Adds FTP user to the web server's group.
# ------------------------------------------------------------------------------
if ! id -u "$FTP_USER" &>/dev/null; then
    echo "Creating FTP user: ${FTP_USER}..."
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    
    # Grant group membership so FTP user can collaborate with www-data
    usermod -aG www-data "$FTP_USER"
    
    # Ensure proper directory ownership
    chown -R "$FTP_USER":www-data /var/www/html
fi

# ------------------------------------------------------------------------------
# 🏰 STEP 3: PREPARE SECURE CHROOT DIRECTORY
# vsftpd requires a completely empty, root-owned directory for internal security jailing.
# ------------------------------------------------------------------------------
mkdir -p /var/run/vsftpd/empty

# ------------------------------------------------------------------------------
# 🌐 STEP 4: INJECT PASSIVE IP ADDRESS
# Replaces PASV_ADDR_PLACEHOLDER in vsftpd.conf with the IP address from .env
# (defaults to 127.0.0.1 for local container-to-host connectivity).
# ------------------------------------------------------------------------------
PASV_ADDR="${FTP_PASV_ADDRESS:-127.0.0.1}"
sed -i "s/PASV_ADDR_PLACEHOLDER/${PASV_ADDR}/g" /etc/vsftpd.conf

# ------------------------------------------------------------------------------
# 🚀 STEP 5: LAUNCH VSFTPD AS PID 1
# `exec` replaces the shell process with vsftpd, ensuring clean signal handling.
# ------------------------------------------------------------------------------
echo "Starting vsftpd in foreground..."
exec vsftpd /etc/vsftpd.conf
