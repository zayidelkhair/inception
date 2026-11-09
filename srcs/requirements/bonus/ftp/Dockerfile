# ==============================================================================
# 📜 FILE: srcs/requirements/bonus/ftp/Dockerfile
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for the FTP (File Transfer
#    Protocol) server using `vsftpd` (Very Secure FTP Daemon) for zsid-ele's
#    Inception infrastructure. It installs vsftpd, applies our secure chroot
#    configuration, registers the user setup script, and exposes the command
#    port (21) and passive data ports (21100-21110).
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    This builds the Secret Cargo Delivery Chute for zsid-ele!
#    We install a high-speed pneumatic package tube (vsftpd). We tell the guard:
#    - "Listen for delivery trucks knocking on Door 21."
#    - "When packages arrive, pass them through cargo bays 21100 to 21110!"
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    - "Why is a range of ports (21100-21110) exposed in addition to port 21?"
#      Answer: Port 21 is only for the FTP control channel (commands & logins).
#      Actual file transfers and directory listings require separate data ports
#      in FTP Passive Mode (`PASV`), which we constrain to 21100-21110 so Docker
#      can map them reliably to the host.
# ==============================================================================

# 🧱 BASE LAYER: Penultimate stable Debian release
FROM debian:bookworm

# 🏷️ REBRANDING METADATA:
LABEL maintainer="zsid-ele <zsid-ele@student.42abudhabi.ae>"
LABEL project="Inception - 42 Abu Dhabi"

# ------------------------------------------------------------------------------
# 📦 PACKAGE INSTALLATION:
# Installs vsftpd (Very Secure FTP Daemon) and cleans up package cache.
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# ⚙️ CONFIGURATION & SCRIPTS:
# Copies vsftpd configuration and automated user provisioning script.
# ------------------------------------------------------------------------------
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp_setup.sh /usr/local/bin/ftp_setup.sh
RUN chmod +x /usr/local/bin/ftp_setup.sh

# ------------------------------------------------------------------------------
# 🚪 PORT EXPOSURE:
# - Port 21: FTP command and authentication channel.
# - Ports 21100-21110: Passive data ports for file uploads/downloads.
# ------------------------------------------------------------------------------
EXPOSE 21 21100-21110

# ------------------------------------------------------------------------------
# 🚀 ENTRYPOINT:
# Runs `ftp_setup.sh` to configure user credentials and launch vsftpd.
# ------------------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/ftp_setup.sh"]
