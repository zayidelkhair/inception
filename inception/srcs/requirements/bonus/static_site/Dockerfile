# ==============================================================================
# 📜 FILE: srcs/requirements/bonus/static_site/Dockerfile
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for a standalone static HTML
#    website. It uses Python 3's built-in `http.server` module to serve static
#    assets (HTML, CSS) on port 3000 without requiring PHP, Apache, or databases.
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    This is the Painted Wooden Welcome Billboard!
#    We start with a clean room (Debian Bookworm), install a friendly robot
#    helper (Python 3), nail our painted welcome sign to the wall (`COPY src`),
#    and tell the robot: *"Whenever someone knocks on door 3000, show them the
#    sign instantly without waking up the chef or the librarian!"*
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    - "Does this site use PHP or a database?"
#      Answer: NO! It is a pure static HTML page served via Python's lightweight
#      HTTP server to prove we can deploy non-PHP services cleanly.
#    - "How is it reached?"
#      Answer: Through NGINX at `https://zsid-ele.42.fr/static/` via reverse proxy.
# ==============================================================================

# 🧱 BASE LAYER: Penultimate stable Debian release
FROM debian:bookworm

# ------------------------------------------------------------------------------
# 📦 PACKAGE INSTALLATION:
# Installs Python 3 to provide the lightweight `http.server` utility.
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# 📂 FILES & WORKING DIRECTORY:
# Copies HTML and CSS files into the web directory.
# ------------------------------------------------------------------------------
COPY src /var/www/html
WORKDIR /var/www/html

# ------------------------------------------------------------------------------
# 🚪 PORT EXPOSURE:
# Internal port 3000 (accessible only by NGINX inside the inception_net network).
# ------------------------------------------------------------------------------
EXPOSE 3000

# ------------------------------------------------------------------------------
# 🚀 ENTRYPOINT:
# Runs Python's built-in HTTP server listening on port 3000 in foreground.
# ------------------------------------------------------------------------------
ENTRYPOINT ["python3", "-m", "http.server", "3000"]
