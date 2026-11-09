# ==============================================================================
# 📜 FILE: srcs/requirements/bonus/redis/Dockerfile
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for the Redis in-memory cache
#    server for zsid-ele's Inception infrastructure. It installs `redis-server`
#    from Debian Bookworm, copies our tuned cache configuration file, exposes
#    internal port 6379, and runs the server in the foreground (`--daemonize no`).
#
# 🧒 KID-FRIENDLY CONCEPT & STORY:
#    This builds the nest for Redis the Memory Squirrel in zsid-ele's kingdom!
#    We install a fast-talking counter desk (redis-server), hand the squirrel
#    his rulebook (redis.conf), and tell him: *"Never go hide in the back closet
#    (--daemonize no)! Stay right at the front desk so everyone can see you working!"*
#
# 🎓 EVALUATION CHECKPOINT:
#    Evaluators will ask:
#    - "Why is `--daemonize no` specified?"
#      Answer: Docker containers need PID 1 to run in the foreground. If Redis
#      daemonizes (forks into the background), the container immediately exits!
#    - "How is Redis connected to WordPress?"
#      Answer: Through the `redis-cache` WordPress plugin communicating over
#      the internal Docker bridge network on port 6379.
# ==============================================================================

# 🧱 BASE LAYER: Penultimate stable Debian release
FROM debian:bookworm

# 🏷️ REBRANDING METADATA:
LABEL maintainer="zsid-ele <zsid-ele@student.42abudhabi.ae>"
LABEL project="Inception - 42 Abu Dhabi"

# ------------------------------------------------------------------------------
# 📦 PACKAGE INSTALLATION:
# Installs Redis server engine and cleans package lists to keep image small.
# ------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends redis-server && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# ⚙️ CONFIGURATION & PORT:
# - Copies custom configuration (memory caps, eviction policy).
# - Declares internal listening port 6379.
# ------------------------------------------------------------------------------
COPY conf/redis.conf /etc/redis/redis.conf
EXPOSE 6379

# ------------------------------------------------------------------------------
# 🚀 ENTRYPOINT:
# Launches Redis with our configuration, forcing foreground execution.
# ------------------------------------------------------------------------------
ENTRYPOINT ["redis-server", "/etc/redis/redis.conf", "--daemonize", "no"]
